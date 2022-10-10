// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2021 - 2022
// --------------------------------------------------------------------
// Nombre del archivo: contador.v
//
// Descripción: Este código Verilog implementa un contador parametrizable de n bits 
// (de mayor a menor o de menor a mayor) con la siguiente funcionalidad de sus entradas y salidas:
// 1. iCLK, Reloj activo por flanco de subida.
// 2. iRST_n, Reset activo a nivel bajo.
// 3.	iENABLE, Contador en OFF (nivel bajo) o ON (nivel alto)
//	4. iUP_DOWN, Si es 1 cuenta de menor a mayor y si es 0 al revés
//	5. oCOUNT, valor de la cuenta
//	6. oTC, indica cuando la cuenta llega al final (depende de iUP_DOWN)
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 23/02/2022
//
// Autor: Carlos Tejedo Fuster
// Ordenador de trabajo: Personal
//
// --------------------------------------------------------------------

module contador (iCLK, iRST_n, iENABLE, iUP_DOWN, oCOUNT, oTC, oTCMedios);

	//Declaración de parámetros
	parameter fin_cuenta = 20; //Hasta donde hay que contar
	parameter n = $clog2(fin_cuenta-1); //Calculo bits necesarios
	
	//Declaracion de entradas y salidas
	input iCLK, iRST_n, iENABLE, iUP_DOWN;
	output reg [n-1:0] oCOUNT;
	output oTC,oTCMedios;
	
	//process
	always @(posedge iCLK)
	begin
		if (!iRST_n)			// Si iRST_n esta a 0, oCOunt será cero y el contador no funcionara
			oCOUNT <= 0;
		else if (iENABLE)		//Si iRST_n y iENABLE son 1 se ejecuta lo siguiente 
			begin
			if (iUP_DOWN)		//Si iUP_DOWN es 1, contara hacia arriba
				begin
				if(oCOUNT == fin_cuenta-1) //Si ha llegado al final volverá al 0
					oCOUNT <= 0;
				else
					oCOUNT <= oCOUNT + 1; //Si no ha llegado sumara uno al valor anterior
				end
			else						//Si iUP_DOWN es 0, contara hacia bajo
				begin
				if(oCOUNT == 0)	//Si ha llegado al final, 0 en este caso, pasara al numero mayor
					oCOUNT <= fin_cuenta-1;
				else					//Si no ha llegado, restara uno
				
					oCOUNT <= oCOUNT -1;
				end
			end
				
	end
	
//La asignacion que hay a continuacion evalua hacia donde cuenta el contador para determinar si ha llegado
//al final de la cuenta. Si lo ha hecho, le asignara a oTC el valor de iENABLE. 
	
	assign oTC = (iUP_DOWN)? ((oCOUNT == (fin_cuenta-1))? iENABLE :0) : ((oCOUNT == 0)? iENABLE : 0);
	assign oTCMedios = (iUP_DOWN)? ((oCOUNT == (fin_cuenta/2))? iENABLE :0) : ((oCOUNT == 0)? iENABLE : 0);
endmodule 