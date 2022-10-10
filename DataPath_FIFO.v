// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Integración de Sistemas Digitales
// Curso 2022 - 2023
// --------------------------------------------------------------------
// Nombre del archivo: DataPath_FIFO.v
//
// Descripción: Este código Verilog implementa el DATAPATH de la FIFO solicitada. Cuenta con los
// siguientes modulos:
//  1.  Countw, contador que indica en que posicion se debe escribir
//  2.  Countr, contador que indica que posisicon se debe leer
//  3.  USE_DW, contador que indica las posiciones de memoria ocupadas 
//	4.  ram_dp, memoria ram. 
//
//  Y con la siguiente relación de entradas y salidas:
//  1.  CLK, Reloj activo por flanco de subida
//  2.  RST_n, Reset activo a nivel bajo
//  3.	e_countr, enable de Countr
//	4.  e_countw, enable de Countw
//	5.  e_USE_DW, enable de USE_DW
//	6.  control, flag utilizada para realizar, o no, un bypass en la salida
//  7.  WREN, habilita la escritura en la RAM
//  8.  RDEN, habilita la lectura en la RAM
//  9.  data_in, bus de entrada de datos
//  10. USE_DW, salida del contador USE_DW
//  11. data_out, bus de salida de datos
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 09/10/2022
//
// Autores: Carlos Tejedo Fuster y Jaime Oviedo Goberna 
// Ordenador de trabajo: Personal
//
// --------------------------------------------------------------------


module DataPath_FIFO (
    input  CLK, RST_n, 
    input  e_countr, e_countw, e_USE_DW, UD_USE_DW, control,
    input WREN, RDEN,
    input [7:0] data_in,
    output [4:0] USE_DW,
    output reg [7:0] data_out
    
);
    
wire [$clog2(31)-1:0] wraddress; 
wire [$clog2(31)-1:0] rdaddress;
wire [7:0] DATA;


//CONTADOR COUNTW
contador Countw
(
	.iCLK(CLK) ,	// input  iCLK_sig
	.iRST_n(RST_n) ,	// input  iRST_n_sig
	.iENABLE(e_countw) ,	// input  iENABLE_sig
	.oCOUNT(wraddress) ,	// output [n-1:0] oCOUNT_sig
	.iUP_DOWN(1'b1)
);
defparam Countw.fin_cuenta = 32; 

//CONTADOR COUNTR
contador Countr
(
	.iCLK(CLK) ,	// input  iCLK_sig
	.iRST_n(RST_n) ,	// input  iRST_n_sig
	.iENABLE(e_countr) ,	// input  iENABLE_sig
	.oCOUNT(rdaddress) ,	// output [n-1:0] oCOUNT_sig
	.iUP_DOWN(1'b1)
);
defparam Countr.fin_cuenta = 32; 

// CONTADOR USE_DW
contador Use_DW
(
	.iCLK(CLK) ,	// input  iCLK_sig
	.iRST_n(RST_n) ,	// input  iRST_n_sig
	.iENABLE(e_USE_DW) ,	// input  iENABLE_sig
	.oCOUNT(USE_DW) ,	// output [n-1:0] oCOUNT_sig
	.iUP_DOWN(UD_USE_DW)
);
defparam Use_DW.fin_cuenta = 32; //FALTA DEFINIR
    
    
    //RAM
ram_dp  Ram_dp (
    .clock(CLK),
    .rden(RDEN),
    .wren(WREN),
    .data_in(data_in), 
    .wraddress(wraddress), 
    .rdaddress(rdaddress),
    .data_out(DATA)


);


//BYPASS de salida. En función del flag control, 
//la salida del dataptah sera la salida de la RAM
//o la entrada de datos
always@(posedge CLK)
begin
	if(control)
		data_out <= data_in;
	else
		data_out <= DATA;
end



endmodule