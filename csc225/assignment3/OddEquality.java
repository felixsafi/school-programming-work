/* 
 * CSC 225 - Assignment 3
 * Name: Felix Safieh
 * Student number: V00962305
 */
 
/* 
Algorithm analysis goes here.
*/
 
 
import java.io.*;
import java.util.*;

public class OddEquality {
    
    static boolean oddEqual(int[] a, int[] b){
		return recursive_oddEqual(a, b, 0, 0, a.length); // call rec fn to solve
    }

	// Once we have an odd sized array compare all elements and return true if all indices equal
	static boolean recursive_oddEqual(int[] a, int [] b, int a_offset, int b_offset, int length){
		if(length%2 != 0){
			for (int i = 0; i < length; i++) {
				if(a[i+a_offset]!=b[i+b_offset]){
					return false;
				}	
			}	
			return true;
		}
		
		int new_length = length / 2; // updates the new lengths to half of the original

		
		return (recursive_oddEqual(a, b, a_offset, b_offset, new_length) && //checks a1/b1 and a2/b2 by offsetting the starting index
		recursive_oddEqual(a, b, a_offset + new_length, b_offset + new_length, new_length)) || 
	   (recursive_oddEqual(a, b, a_offset, b_offset, new_length) && // or checks for a1/a2 and a1/b2
		recursive_oddEqual(a, b, a_offset, b_offset+new_length, new_length)) ||
		(recursive_oddEqual(a, b, a_offset+new_length, b_offset, new_length) && //checks for a2/b1 and a2/b2
		recursive_oddEqual(a, b, a_offset+new_length, b_offset+new_length, new_length));
	}
    
    public static void main(String[] args) {
    /* Read input from STDIN. Print output to STDOUT. Your class should be named OddEquality. 

	You should be able to compile your program with the command:
   
		javac OddEquality.java
	
   	To conveniently test your algorithm, you can run your solution with any of the tester input files using:
   
		java OddEquality inputXX.txt
	
	where XX is 00, 01, ..., 13.
	*/

   	Scanner s;
	if (args.length > 0){
		try{
			s = new Scanner(new File(args[0]));
		} catch(java.io.FileNotFoundException e){
			System.out.printf("Unable to open %s\n",args[0]);
			return;
		}
		System.out.printf("Reading input values from %s.\n",args[0]);
	}else{
		s = new Scanner(System.in);
		System.out.printf("Reading input values from stdin.\n");
	}     
  
        int n = s.nextInt();
        int[] a = new int[n];
        int[] b = new int[n];
        
        for(int j = 0; j < n; j++){
            a[j] = s.nextInt();
        }
        
        for(int j = 0; j < n; j++){
            b[j] = s.nextInt();
        }
        
        System.out.println((oddEqual(a, b) ? "YES" : "NO"));
    }
}
