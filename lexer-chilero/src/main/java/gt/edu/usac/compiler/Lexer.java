package gt.edu.usac.compiler;/*
Copyright (c) 2000 The Regents of the University of California.
All rights reserved.

Permission to use, copy, modify, and distribute this software for any
purpose, without fee, and without written agreement is hereby granted,
provided that the above copyright notice and the following two
paragraphs appear in all copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
*/

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.util.Scanner;
import java.util.concurrent.Callable;

import java_cup.runtime.Symbol;
import picocli.CommandLine;

/** The lexer driver class */
@CommandLine.Command(name = "lexer", mixinStandardHelpOptions = true, version = "0.0.1", description = "Analizador léxico para COOL y el dialecto CHILERO")
public class Lexer implements Callable<Integer>{

	@CommandLine.Option(names = { "-f", "--file" }, description = "Archivo a leer", required = false)
	public File file2;

	@Override
	public Integer call() throws Exception {

		if (file2 != null) {
			BufferedReader brf = Files.newBufferedReader(file2.toPath());
			CoolLexer lexer = new CoolLexer(brf);
			Symbol token;
			while ((token = lexer.next_token()).sym != TokenConstants.EOF) {
				Utilities.dumpToken(System.out, lexer.get_curr_lineno(), token);
			}
		}else{

			Scanner scanner = new Scanner(System.in);
			String input = "";
			System.out.println("****[ANALIZADOR LÉXICO]****");
			System.out.println("Escriba \"exit\" para salir");
			while (!input .equals("exit")) {
				System.out.print("Ingrese la cadena > ");
				input = scanner.nextLine();
				if (input.equals("exit")) {
					break;
				}
				CoolLexer lexer = new CoolLexer(new StringReader(input));
				Symbol token;
				while ((token = lexer.next_token()).sym != TokenConstants.EOF) {
					Utilities.dumpToken(System.out, lexer.get_curr_lineno(), token);
				}
			}
		}
		return 0;
	}

    /** Loops over lexed tokens, printing them out to the console */
    public static void main(String[] args) {
		//condición en caso de que se ingrese algún argumento propio de la app con picocli
		if (args.length == 0 || (new Lexer()).is_command(args)) {
			int exitCode = new CommandLine(new Lexer()).execute(args);
			System.exit(exitCode);
		}else{
	args = Flags.handleFlags(args);

	for (int i = 0; i < args.length; i++) {
	    FileReader file = null;
	    try {
		file = new FileReader(args[i]);
		
		System.out.println("#name \"" + args[i] + "\"");
		CoolLexer lexer = new CoolLexer(file);
		lexer.set_filename(args[i]);
		Symbol s;
		while ((s = lexer.next_token()).sym != TokenConstants.EOF) {
		    Utilities.dumpToken(System.out, lexer.get_curr_lineno(), s);
		}
	    } catch (FileNotFoundException ex) {
		Utilities.fatalError("Could not open input file " + args[i]);
	    } catch (IOException ex) {
		Utilities.fatalError("Unexpected exception in lexer");
	    }
	}		
	}
    }

	/**
	 * Método para asegurarse que no se requiere usar la app con la implementación de picoCLI
	 * @param args Los argumentos de la aplicación
	 * @return Retorna true si se refiere a alguno de los argumentos de la app con picoCLI, de lo contrario es false
	 */
	private boolean is_command(String[] args){
		if (args[0].equals("-f")||args[0].equals("--file")) return true;
		if (args[0].equals("-h")||args[0].equals("--help")) return true;
		if (args[0].equals("-v")||args[0].equals("--version")) return true;
		return false;
	}
}
