/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   /* Cache Signals */
   // Outputs
   wire [4:0] cache_tag_out, cache_tag_out0, cache_tag_out1;
   wire [15:0] cache_data_out, cache_data_out0, cache_data_out1;
   wire cache_hit0, cache_hit1;
   wire cache_dirty0, cache_dirty1;
   wire cache_valid0, cache_valid1;
   // Inputs
   wire cache_enable;
   wire cache_write, cache_write0, cache_write1;
   wire cache_comp;
   wire cache_valid_in;

   wire [4:0] cache_tag_in;
   wire [7:0] cache_index;
   wire [2:0] cache_offset;
   wire [15:0] cache_data_in;

   /* Memory Signals */
   // Outputs
   wire [15:0] mem_data_out;
   wire mem_stall;
   // Inputs
   wire [15:0] mem_address;
   wire mem_write, mem_read;

   /* Error Signals */
   wire cache_error0, cache_error1, mem_error, fsm_error;

   /* FSM signals */
   wire victimize;
   wire real_hit;

   /* Two-way & Victimway signals */
   wire set;
   wire victim_out, victim_in, victim;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cache_tag_out0),
                          .data_out             (cache_data_out0),
                          .hit                  (cache_hit0),
                          .dirty                (cache_dirty0),
                          .valid                (cache_valid0),
                          .err                  (cache_error0),
                          // Inputs
                          .enable               (cache_enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_tag_in),
                          .index                (cache_index),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write0),
                          .valid_in             (cache_valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (cache_tag_out1),
                          .data_out             (cache_data_out1),
                          .hit                  (cache_hit1),
                          .dirty                (cache_dirty1),
                          .valid                (cache_valid1),
                          .err                  (cache_error1),
                          // Inputs
                          .enable               (cache_enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_tag_in),
                          .index                (cache_index),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write1),
                          .valid_in             (cache_valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (),  
                     .err               (mem_error),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_address),
                     .data_in           (cache_data_out),
                     .wr                (mem_write),
                     .rd                (mem_read));
   // Your code here
   /* Assigns */
   assign cache_tag_in = Addr[15:11];
   assign cache_index = Addr[10:3];
   assign DataOut = cache_data_out; // data presented to system will only ever be data from cache
   assign err = cache_error0 | cache_error1 | mem_error | fsm_error; // error is the OR of caches and memory errors

   /* TWO-WAY LOGIC */
   // Only on access_write, we need to writeback to memory(comp = 0), otherwise we write from memory to cache
   assign cache_data_in = (cache_write & ~cache_comp) ? mem_data_out : DataIn;

   // Hit goes high if either cache is valid and hit
   assign real_hit = (cache_valid0 & cache_hit0) | (cache_valid1 & cache_hit1);

   // Find the correct way, 1 or 0, by muxing one of the hit signals, and choosing victim on miss
   assign set = real_hit ? ((cache_valid1 & cache_hit1) ? 1'b1 : 1'b0) : victim;

   // Victimize goes high if either cache missed and is dirty
   assign victimize = set ? (cache_valid1 & cache_dirty1) : (cache_valid0 & cache_dirty0);
 
   // Assign output data based on way
   assign cache_tag_out = set ? cache_tag_out1 : cache_tag_out0;
   assign cache_data_out = set ? cache_data_out1 : cache_data_out0;

   // Only one cache is writable at a time, based on way, enable signal too hard to do from schematic
   assign cache_write0 = set ? 1'b0 : cache_write;
   assign cache_write1 = set ? cache_write : 1'b0;

   /* VICTIMWAY */
   // Invert victim state whenver cache is written to or read from (when Done goes high)
   assign victim_in = Done ? ~victim_out : victim_out;

   // DFF to store the victim state
   dff victimway(
      .q(victim_out),
      .d(victim_in),
      .clk(clk),
      .rst(rst)
   );

   /*
   1. When installing a line after a cache miss, install in an invalid block if possible. 
   2. If both ways are invalid, install in way zero. 
   3. If both ways are valid, and a block must be victimized, use victimway after inversion. 
   4. For the D cache, do not invert victimway for instructions that do not read or write cache, 
      or for invalid instructions, or for instructions that are squashed due to branch misprediction. 
   5. For the I cache, invert victimway for each instruction fetched.
   */

   assign victim = (cache_valid0 & ~cache_valid1) ? 1'b1 :
      (~cache_valid0 & cache_valid1) ? 1'b0 :
      (cache_valid0 & cache_valid1) ? ~victim_out : 1'b0; 

   // Modify victim state based on D or I cache (Later)
         

   /* CACHE CONTROLLER */
   cache_controller cache_fsm(
   // Outputs
   .Done(Done),
   .Stall(Stall),
   .CacheHit(CacheHit),
   .error(fsm_error),
   .cache_enable(cache_enable),
   .cache_offset(cache_offset),
   .cache_comp(cache_comp),
   .cache_write(cache_write),
   .cache_valid_in(cache_valid_in),
   .mem_addr(mem_address),
   .mem_write(mem_write),
   .mem_read(mem_read),
   // Inputs
   .clk(clk),
   .rst(rst),
   .system_read(Rd),
   .system_write(Wr),
   .system_tag(Addr[15:11]),
   .system_index(Addr[10:3]),
   .system_offset(Addr[2:0]),
   .real_hit(real_hit),
   .victimize(victimize),
   .cache_tag_out(cache_tag_out),
   .mem_stall(mem_stall)
);


endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: