// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Integración de Sistemas Digitales
// Curso 2022 - 2023
// --------------------------------------------------------------------
// Nombre del archivo: FSM_FIFO.v
//
// Descripción: Este código Verilog implementa el maquina de estados de la FIFO solicitada.
// Cuenta con la siguiente relación de entradas y salidas:
//
//	ENTRADAS
//  1.  CLK, Reloj activo por flanco de subida
//  2.  RESET_N, Reset activo a nivel bajo y asincrono
//  3.	CLEAR_N, Reset activo a nivel bajo y sincrono
//	4. 	USE_DW, indica las posiciones de memoria ocupadas
//  5.  WRITE, se activa cuando se debe escribir
//  6.  READ, se activa cuando se debe leer
//
//	SALIDAS
//	7.  F_FULL_N, Flag activo a nivel bajo que nos indica cuando la memoria esta llena
//	8.  F_EMPTY_N, Flag activo a nivel bajo que nos indica cuando la memoria esta vacia
//	9.  UD_USE_DW, indica si el contador USE_DW tiene que contar hacia arriba o haccia debajo
//  10.	e_countr, enable de Countr
//	11. e_countw, enable de Countw
//	12. e_USE_DW, enable de USE_DW
//	13. control, flag utilizada para realizar, o no, un bypass en la salida
//	14.	WREN, habilita la escritura
//	15. RDEN, habilita la lectura
//  
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 09/10/2022
//
// Autores: Carlos Tejedo Fuster y Jaime Oviedo Goberna 
// Ordenador de trabajo: Personal
//
// --------------------------------------------------------------------
module FSM_FIFO (

	input CLK, RESET_N,
	input CLEAR_N, READ, WRITE, 
	input [4:0] USE_DW,
	output reg F_FULL_N, F_EMPTY_N, UD_USE_DW,
	output reg e_countw,e_countr, e_USE_DW, WREN, RDEN, control

);

reg [1:0] state, next_state;
localparam [1:0] vacio = 2'b00, otros = 2'b01, lleno = 2'b10;

//Proceso para cambiar de estado
always @(posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)
			state <= vacio;
		else if (!CLEAR_N)
			state <= vacio;
		else
			state <= next_state;
	end
	
//Proceso que define el estado siguiente
always @(WRITE, READ, USE_DW, state)
begin
		case (state)
		
			vacio:
				begin
					if(WRITE == 1 && READ == 0)
						next_state = otros;
					else
						next_state = vacio;
				end
				
			otros:
				begin
					if (WRITE)
						if(READ)
							next_state = otros;
						else
							begin
								if(USE_DW == 31)
									next_state = lleno;
								else
									next_state = otros;
							end
					else
						if(!READ)
							next_state = otros;
						else
							begin
								if(USE_DW == 1)
									next_state = vacio;
								else
									next_state = otros;
							end
				end
					
			lleno:
				begin
					if (WRITE)
						next_state = lleno; 
					else
						if (READ)
							next_state = otros;
						else
							next_state = lleno;
				end
				
			default: next_state = vacio;
		endcase 
			
	end
	
//Proceso que define las salidas
always @(state, READ, WRITE)
	begin
		case (state)
			vacio:
				begin
					F_EMPTY_N = 0;
					F_FULL_N = 1;
					
					if (WRITE && READ)
						begin
							WREN = 1;
							RDEN = 1;
							e_countw = 0;
							e_countr = 0;
							e_USE_DW = 0;
							UD_USE_DW = 1;
							control = 1;
						end
					else if (WRITE == 1 && READ == 0)
						begin
							WREN = 1;
							RDEN = 0;
							e_countw = 1;
							e_countr = 0;
							e_USE_DW = 1;
							UD_USE_DW = 1;
							control = 0;

						end
					else
						begin
							WREN = 0;
							RDEN = 0;
							e_countw = 0;
							e_countr = 0;
							e_USE_DW = 0;
							UD_USE_DW = 1;
							control = 0;

						end
					
				end
				
			otros:
				begin
					F_EMPTY_N = 1;
					F_FULL_N = 1;
					control = 0;

					
					if (WRITE)
						if (READ)
							begin
								WREN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
								RDEN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
								e_countw = 1;
								e_countr = 1;
								e_USE_DW = 0;
								UD_USE_DW = 1;
							end
						else
							begin
								WREN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
								RDEN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
								e_countw = 1;
								e_countr = 0;
								e_USE_DW = 1;
								UD_USE_DW = 1;
							end
						
					else if (!WRITE && READ)
						begin
							WREN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							RDEN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							e_countw = 0;
							e_countr = 1;
							e_USE_DW = 1;
							UD_USE_DW = 0;
						end
						
					else
						begin
							WREN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							RDEN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							e_countw = 0;
							e_countr = 0;
							e_USE_DW = 0;
							UD_USE_DW = 1;
						end
						
				end
				
			lleno:
				begin
					F_EMPTY_N = 1;
					F_FULL_N = 0;
					control = 0;

					
					if (WRITE && READ)
						begin
							WREN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							RDEN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							e_countw = 1;
							e_countr = 1;
							e_USE_DW = 0;
							UD_USE_DW = 1;
				
						end
					else if (!WRITE && READ)
						begin
							WREN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							RDEN = 1; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							e_countw = 0;
							e_countr = 1;
							e_USE_DW = 1;
							UD_USE_DW = 0;
						end
					else
						begin
							WREN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							RDEN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
							e_countw = 0;
							e_countr = 0;
							e_USE_DW = 0;
							UD_USE_DW = 1;
						end
					
				end
			default:
				begin
					F_EMPTY_N = 1;
					F_FULL_N = 1;
					control = 0;
					WREN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
					RDEN = 0; //SIEMPRE QUE SE ACTIVE A NIVEL ALTO. REVISAR
					e_countw = 0;
					e_countr = 0;
					e_USE_DW = 0;
					UD_USE_DW = 1;
				end

		endcase
	end

//property vaciado; //opcion para reuso de propiedades
	//begin
//	@(posedge CLK) not (READ==1'b1 && F_EMPTY_N==1'b0 && WRITE==1'b0);
	//end
//endproperty
//sobrevaciado:assert property  (vaciado) else $error("leyendo de una fifo vacia");

always@(posedge CLK)
begin
	if(READ==1'b1 && F_EMPTY_N==1'b0 && WRITE==1'b0)
		$display("leyendo de una fifo vacia");
end
endmodule 