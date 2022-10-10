// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Integración de Sistemas Digitales
// Curso 2022 - 2023
// --------------------------------------------------------------------
// Nombre del archivo: tb_fifo_SV.v
//
// Descripción: Este código SystemVerilog implementa el testbench del
// diseño FIFO.v
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 09/10/2022
//
// Autores: Carlos Tejedo Fuster y Jaime Oviedo Goberna 
// Ordenador de trabajo: Personal
//
// --------------------------------------------------------------------

`timescale 1ns/100ps

module tb_FIFO ();

localparam T = 20;
logic  		CLK, RST_n;
logic		READ, WRITE, CLEAR_N;
logic	[7:0]	DATA_IN;
logic 	[7:0]	DATA_OUT;
logic	[4:0]	USE_DW;
logic			F_FULL_N, F_EMPTY_N;


FIFO DUV
(
	.DATA_IN(DATA_IN) ,	
	.READ(READ) ,
	.WRITE(WRITE) ,
	.CLEAR_N(CLEAR_N) ,
	.RESET_N(RST_n) ,	
	.CLOCK(CLK) ,	
	.DATA_OUT(DATA_OUT) ,	
	.USE_DW(USE_DW) ,	
	.F_FULL_N(F_FULL_N) ,
	.F_EMPTY_N(F_EMPTY_N)
);




//GENERACION DEL RELOJ
initial
begin
CLK=0;
forever 
	begin 
	#(T/2) CLK = !CLK; 	
	end
end

initial
begin
	reset();
	
	//INICIALIZAMOS SEÑALES
	#(T*5)
	WRITE=0;
	READ=0;

	//TEST CASO 1
	#(T*10);
	CASO_1();

	//TEST CASO 2
	#(T*5);
	CASO_2();

	//TEST CASO 3
	#(T*5);
	CASO_3();

	//TEST CASO 4
	#(T*5);
	CASO_4();

	//TEST CASO 5
	#(T*5);
	CASO_5(8,300);

	//TEST CASO 6
	#(T*5);
	CASO_6();

	//TEST CASO 7
	#(T*5);
	CASO_7();

	//TEST CASO 8
	#(T*5);
	CASO_8();

	//TEST CASO 9
	#(T*5);
	CASO_9();

	//TEST CASO 10
	#(T*5);
	CASO_10();

	//FIN DE LA SIMULACION
	#(T*5);
	$finish;
end

//TASK PARA RESET
//Los cambios son realizados en el flanco de bajada del CLK para aportar
//mas estabilidad al hardware
task reset;
begin
	@(negedge CLK);
	RST_n = 0;
	repeat(10) @(negedge CLK);
	RST_n = 1;
	
end
endtask 

//TASK CLEAR
//COMPROBAMOS EL FUNCIONAMIENTO DE LA SEÑAL CLEAR_N
task clear;
	begin
		@(negedge CLK);
		CLEAR_N = 0;
		repeat(10) @(negedge CLK);
		CLEAR_N = 1;
	
	end
endtask 


//TASK ESCRITURA
//NOS PERMITTE ESCRIBIR EN LA MEMORIA
task escribe;
input [7:0] valor;
begin
	
	@(negedge CLK);
	#1
	WRITE = 0;
	
	@(negedge CLK);
	#1
	DATA_IN = valor;

	@(negedge CLK);
	#1
	WRITE = 1;
	@(negedge CLK);
	#1
	WRITE = 0;
	
end
endtask

//TASK LEER
//NOS PERMITE LEER DE LA MEMORIA
task leer;
begin
	@(negedge CLK);
	#1
	READ = 1;
	
	@(negedge CLK);
	#1
	READ = 0;
	
end
endtask

//TASK ESCRIBE_N_VECES
//NOS PERMITE ESCRIBIR UN NUMERO DETERMINADO DE VECES
//TRAS DARLE UN VALOR, ESTE AUMENTARA UNO EN CADA ESCRITURA
task escribe_N_veces;
input [7:0] valor;
input [7:0] N;
begin
	
repeat(N)
		begin
			escribe(valor);
			valor = valor+1; 
		end
	
	
end
endtask


//CASOS DE VERIFICACION

//CASO 1. Si FIFO vacia y activamos READ & WRITE.
//Comprobar que primero escribe y después lee
//En este caso también verificamos si la FIFO permite lectura y escritura simultanea.
//***Se puede observar que dentro del fork join hay un retraso temporal, ha sido programado
//***de esta manera para conseguir que ambas task se ejecuten a la vez, ya que la task de lectura
//***es mas rapida que la de escritura
task CASO_1();
begin
	reset();
	#(T*2);
	fork
		escribe(21);
		#(T*2)	leer();
	join
	
	@(posedge CLK);
	assert(DATA_OUT == 21)
	else
		$error("La FIFO no permite lectura y escritura simultanea");
end
endtask

//CASO 2. Si FIFO llena y activamos READ & WRITE.
//Comprobar que primero lee y luego escribe
//***Se puede observar que dentro del fork join hay un retraso temporal, ha sido programado
//***de esta manera para conseguir que ambas task se ejecuten a la vez, ya que la task de lectura
//***es mas rapida que la de escritura
task CASO_2();
begin
	reset();
	//Escribimos 32 datos	
	#(T*2);
	escribe_N_veces(4,5);
	#(T*2);
	fork
	escribe(40);
	#(T*2)	leer();	
	join

	repeat(2)@(posedge CLK);
	assert(DATA_OUT==4)
		begin
			repeat (4) leer();
			#(T);
			leer();
			#(T);
			assert(DATA_OUT == 40)
			else
				$error("Error en caso 2");
		end
	else
		$error("Error en caso 2");
	
	
	
end
endtask

//CASO 3. Si FIFO llena y activamos WRITE.
//Comprobar que no debe machacar datos
task CASO_3;
begin
	CASO_6();

	#(T);
	escribe(8);
	#(T*5);
	leer();

	@(posedge CLK);
	assert(DATA_OUT != 8)
	else
		$error("Se están machacando datos");
end
endtask

//CASO 4. Si FIFO vacía y activamos READ. 
//Comprobar la salida
task CASO_4;
begin
	reset();
	#(T)
	leer();
end
endtask

//CASO 5.
//¿Almacena palabras de 8bits?
task CASO_5;
	input [0:7] 	palabra_valida;
	input [0:15]  	palabra_no_valida;
begin
	reset();
	#(T)
	escribe(palabra_valida);
	leer();
	repeat(2) @(posedge CLK);
	assert(palabra_valida==DATA_OUT)
	else
		$error("No cabe una palabra de 8 bits");

	#(T);
	escribe(palabra_no_valida);
	leer();

	repeat(2) @(posedge CLK);
	assert(palabra_no_valida != DATA_OUT)
	else
		$error("Cabe una palabra de más de 8 bits");
		
end
endtask


//CASO 6.
//¿Almacena 32 items?
task CASO_6;
begin

	//Hacemos un reset para asegurarnos que la FIFO está vacía
	reset();

	//Escribimos 32 datos
	#(T*2);
	escribe_N_veces(0,32);

	@(posedge CLK);
	assert(USE_DW == 0 && F_FULL_N==0 && F_EMPTY_N==1)
	else
		$error("HAY UN ERROR AL INTENTAR LLENAR LA FIFO");

end
endtask

//CASO 7.
//¿Se indica el número de posiciones ocupadas?
task CASO_7;
begin

	//Hacemos un reset para asegurarnos que la FIFO está vacía
	reset();

	//Escribimos 32 datos
	#(T*2);
	escribe_N_veces(0,7);

	@(posedge CLK);
	assert(USE_DW == 7)
	else
		$error("HAY UN ERROR AL MOSTRAR LAS POSICIONES OCUPADAS");

end
endtask
//CASO 8.
//¿Se borra al activar RESET?
task CASO_8;
begin
	escribe(8);
	#(T);
	reset();

	@(posedge CLK);
	assert(USE_DW == 0 && F_FULL_N==1 && F_EMPTY_N==0)
	else
		$error("HAY UN ERROR CON EL RESET");

end
endtask

//CASO 9.
//¿Se borra al activar CLEAR?
task CASO_9;
begin 
	escribe(8);
	#(T)
	clear();

	@(posedge CLK);
	assert(USE_DW == 0 && F_FULL_N==1 && F_EMPTY_N==0)
	else
		$error("HAY UN ERROR CON EL CLEAR");
end
endtask

//CASO 10
//FUNCIONAMIENTO NORMAL
task CASO_10;
begin
	reset();

	#(T*2);
	escribe_N_veces(10,6);
	#(T*2);

	leer();

	repeat(2) @(posedge CLK);
	assert(DATA_OUT==10)
		begin
			#(T);
			leer();
			repeat(2) @(posedge CLK);
			assert(DATA_OUT==11)
			else
				$error("Error en la segunda parte del caso 10");
		end
	else
		$error("Error en la primera parte del caso 10");
end
endtask


endmodule 