////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lei Li -- lile@iis.ee.ethz.ch                              //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 // 
// Design Name:    div_sqrt_top                                               // 
// Module Name:    div_sqrt_top.sv                                            //
// Project Name:   The shared divisor and square root                         //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    The top of div and sqrt                                    //
//                                                                          //
//                                                                            //
// Revision:       16/01/2017                                                 //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs::*;

module div_sqrt_top
  (//Input
   input logic              Clk_CI,
   input logic              Rst_RBI,
   input logic              Div_start_SI,
   input logic              Sqrt_start_SI,


   //Input Operands
   input logic [C_OP-1:0]   Operand_a_DI,
   input logic [C_OP-1:0]   Operand_b_DI,
   input logic [C_RM-1:0]   RM_SI,    //Rounding Mode


   output logic [31:0]      Result_DO,
 
   //Output-Flags
   output logic             Exp_OF_SO,
   output logic             Exp_UF_SO,
   output logic             Div_zero_SO,
   output logic             Ready_SO, 
   output logic             Done_SO
 );
   


  logic [C_MANT-1:0]        Mant_res_DO;
  logic [C_EXP-1:0]         Exp_res_DO;
  logic                     Sign_res_DO;

   assign Result_DO =   {Sign_res_DO,Exp_res_DO, Mant_res_DO};   

   //Operand components
   logic                   Sign_a_D;
   logic                   Sign_b_D;
   logic [C_EXP:0]         Exp_a_D;
   logic [C_EXP:0]         Exp_b_D;
   logic [C_MANT:0]        Mant_a_D;
   logic [C_MANT:0]        Mant_b_D;

   logic [C_EXP+1:0]       Exp_z_D;
   logic [C_MANT:0]        Mant_z_D;
   logic                   Sign_z_D;
   logic                   Start_S;
   logic [C_RM-1:0]        RM_dly_S;
   logic                   Mant_zero_S_a, Mant_zero_S_b;
   logic                   Div_enable_S;
   logic                   Inf_a_S;
   logic                   Inf_b_S;
   logic                   Zero_a_S;
   logic                   Zero_b_S;
   logic                   NaN_a_S;
   logic                   NaN_b_S;
   logic [31:0]            Operand_a_dly_D;
   logic [31:0]            Operand_b_dly_D;
 //
preprocess  precess_U0
 (
   .Clk_CI                (Clk_CI             ),
   .Rst_RBI               (Rst_RBI            ),
   .Div_start_SI          (Div_start_SI       ),
   .Sqrt_start_SI         (Sqrt_start_SI      ),
   .Operand_a_DI          (Operand_a_DI       ),
   .Operand_b_DI          (Operand_b_DI       ),
   .RM_SI                 (RM_SI              ),    //Rounding Mode

   .Start_SO              (Start_S            ),
 
   .Exp_a_DO_norm         (Exp_a_D            ),
   .Exp_b_DO_norm         (Exp_b_D            ),
   .Mant_a_DO_norm        (Mant_a_D           ),

   .Mant_b_DO_norm        (Mant_b_D           ),
   .RM_dly_SO             (RM_dly_S           ),  
   .Operand_a_dly_DO      (Operand_a_dly_D    ),
   .Operand_b_dly_DO      (Operand_b_dly_D    ),
   .Sign_z_DO             (Sign_z_D           ),
   .Inf_a_SO              (Inf_a_S            ),
   .Inf_b_SO              (Inf_b_S            ),
   .Zero_a_SO             (Zero_a_S           ),
   .Zero_b_SO             (Zero_b_S           ),
   .NaN_a_SO              (NaN_a_S            ),
   .NaN_b_SO              (NaN_b_S            )
   );


 nrbd_nrsc   nrbd_nrsc_U0
  (//Input
   .Clk_CI                (Clk_CI            ),
   .Rst_RBI               (Rst_RBI            ),
   .Div_start_SI          (Div_start_SI       ) ,
   .Sqrt_start_SI         (Sqrt_start_SI      ),
   .Start_SI              (Start_S            ),
   .Div_enable_SO         (Div_enable_S       ),

   .Exp_a_DI              (Exp_a_D            ),
   .Exp_b_DI              (Exp_b_D            ),
   .Mant_a_DI             (Mant_a_D           ),
   .Mant_b_DI             (Mant_b_D           ),

  //output
   .Ready_SO              (Ready_SO            ),
   .Done_SO               (Done_SO             ),
  // the prenormalized data
   .Exp_z_DO              (Exp_z_D            ),
   .Mant_z_DO             (Mant_z_D           )
    );


  
 fpu_divsqrt_norm  fpu_norm_U0
  (
   .Mant_in_DI            (Mant_z_D           ),
   .Exp_in_DI             (Exp_z_D            ),
   .Sign_in_DI            (Sign_z_D           ),
   .Div_enable_SI         (Div_enable_S       ), 

   .Operand_a_dly_DI      (Operand_a_dly_D    ),
   .Operand_b_dly_DI      (Operand_b_dly_D    ),
   .Inf_a_SI              (Inf_a_S            ),
   .Inf_b_SI              (Inf_b_S            ),
   .Zero_a_SI             (Zero_a_S           ),
   .Zero_b_SI             (Zero_b_S           ),
   .NaN_a_SI              (NaN_a_S            ),
   .NaN_b_SI              (NaN_b_S            ),
   //Rounding Mode

  
   .RM_SI                 (RM_dly_S              ),    //Rounding Mode

   .Mant_res_DO           (Mant_res_DO        ),
   .Exp_res_DO            (Exp_res_DO         ),
   .Sign_res_DO           (Sign_res_DO        ),
   .Exp_OF_SO             (Exp_OF_SO          ),
   .Exp_UF_SO             (Exp_UF_SO          ),
   .Div_zero_SO           (Div_zero_SO         ) 
   );


 
 
endmodule // 
