####################################################################################################################
#Created by:                 Rony, Joshua
#CruzID:                     jrony
#Date:                       11/22/2018
#Quarter:                    Fall 2018

#Assignment:                 Lab 4: ASCII Decimal to 2SC
#Course Name:                CMPE 012, Computer Systems and Assembly Language
#
#Description:                MARS MIPS simulator program that takes in two program arguments, both within the range of
#                            [-64, 63], outputs them to the user, converts them to 2's complement binary form, sums them,
#                            outputs the sum in decimal form, and then outputs the sum in 2's complement binary form.
#             
#           
#
#General Notes:              This program is intended to run from the MARS IDE.
#
#Note on Program Arguments:  In order to enter program arguments, you must first go to "Settings" in the above
#                            toolbar, and check the "Program Arguments Provided to MIPS Program" box.
#                            Once you compile the program, you will see a field for the program arguments
#                            to be entered in the "Text Segment".  Each program argument must be separated by a space.                           
######################################################################################################################
# PSEUDO CODE:
#
#1). Exception Handling:
#    Check to see if there are exactly 2 values/values are in correct range
#    if(arg1 < -64 or arg1 > 63){
#           print error message;
#}
#   if(arg2 < -64 or arg2 > 63){
#           print error message;
#}
#   if(number of args > 2 or number of args < 2){
#           print error message;
#}
#2). Print values:
#          
#          if(first byte of first arg == 2d){
#                 address = address + 1;
#}        
#          Retrieve arg1 from stack
#          Print arg1
#         Move to arg2 address;
#            if(first byte of arg2 == 2d){
#                   address = address + 1;
#}
#          Retrive arg2 from stack
#          Print arg2
#
#3). Turn Into Binary Form: 
#
#          arg1 = arg1 - 48;
#          arg2 = arg2 - 48;
#          
#          most sig. digit in arg1 = most sig. digit in arg1 * 10
#          most sig. digit in arg1 = most sig digit in arg1 + least sig. digit in arg1
#
#          if(byte 1 of arg1 == 2d){
#               invert bits, add 1; (turn into two's complement negative value
#          arg1 is now in its two's complement binary form
#          REPEAT PROCESS FOR ARG 2!
#          SUM VALUES AND STORE IN $s0!
#
#4). Print as Decimal Using Only syscall 4 or syscall 11 (I will use syscall 11):
#         
#         Determine Number of digits in arg1:
#         int x;
#         int y = 1;
#         while(x != 0){
#          
#              x = arg1%10;
#
#              arg1 = arg1 / 10            
#
#              y = y + 1;
#
#        Now you have the number of digits in arg1.  If arg1 has three digits, y == 3;
#        REPEAT PROCESS FOR ARG2!!
#        
#        Now actually print the values:
#                  
#                   for(int i = 0; i < y; i++){
#                        print arg1[i]; <----use syscall 11
#}                 
#        REPEAT PROCESS FOR ARG2!!
#        
#5). Print Sum of Args in 32 Bit Two's Complement Form:
#        
#                Mask sum using 0x80000000:
#                li $t0, 0x80000000   
#               int x = 0; 
#               while(x != 32){
#                     if(and Sum, $t0 == $t0){
#                          print 1;
#                     }
#                     else if(and Sum, $t0 != $t0){
#                          print 0;
#                     }
#                     x = x + 1;
#                     srl $t0, $t0, 1
#
#

#REGISTER USAGE KEY:
# $t8 = 0 flag register (0x00)
# $t9 = negative flag register (0x2d) (except for the very end of the program where I use it for part of the Morse code operations)
# $s1 = 2's complement binary argument 1
# $s2 = 2's complement binary agrument 2
# $s0 = 2's compelement binary sum of arguments 1 and 2
# The rest of the t-registers and s-registers are used for various purposes throughout the program.

.data

	space: .asciiz " "
	
	newLine: .asciiz "\n"
	
	PrintVals: .asciiz "You entered the decimal numbers:\n"
	
	ErrorMessage1: .asciiz "You must enter exactly 2 program arguments, both within the range [-64, 63].\n"
	
	DecimalSum: .asciiz "The sum in decimal is:\n"

        twosComp: .asciiz "The sum in two's complement binary is:\n"
        
        morsePrompt: .asciiz "The sum in Morse code is:\n"
        
        negSign: .asciiz "-....- "	

.text

  ExceptionHandler:
  
	la $s7, 2
	
	bne $a0, $s7, Exception1
	
	beq $a0, $s7, runProg 
	
	Exception1:
	
	          la $a0, ErrorMessage1
	          
	          li $v0, 4
	          
	          syscall
	          
	          j exit
	          
	          
	runProg:
	la $a0, PrintVals
	
	li $v0, 4
	
	syscall
	
	lw $a0, 0($a1)
	
	syscall
	
	la $a0, space
	
	syscall
	
	lw $a0, 4($a1)
	
	syscall
	
	la $a0, newLine
	
	syscall
	
	syscall
	

	
	
	
	la $t8, 0x00 #condition register
 	la $t9, 0x2d #condition register
 	lw $t1, ($a1)
 	lb $t2, 0($t1)
 	
 	beq $t2, $t9, skipNegative
 	
 	bne $t2, $t9, Arg1Loop
 	
 	skipNegative:
 	         
 	         add $t1, $t1, 1
 	         
 	         lb $t2, ($t1)
 	         
 	         j Arg1Loop
 	
 	Arg1Loop:
 	        
 	        sub $t2, $t2, 48
 	        
 	        or $t3, $t3, $t2
 	        
 	        add $t1, $t1, 1
 	        
 	        lb $t2, ($t1)
 	        
 	        beq $t2, $t8, skipSpace
 	        
 	        sll $t3, $t3, 4
 	        
 	        j Arg1Loop
 	
 	skipSpace:
 	
 	        lw $t1 4($a1)
 	        
 	        lb $t2, 0($t1)
 	        
 	        beq $t2, $t9, skipNegative2
 	        bne $t2, $t9, Arg2Loop
 	     
 	        
       skipNegative2:
               
                add $t1, $t1, 1
                
                lb $t2, ($t1)
                
                j Arg2Loop
                
                                                                                    
       Arg2Loop:
       
       	        sub $t2, $t2, 48
 	        
 	        or $t4, $t4, $t2
 	        
 	        add $t1, $t1, 1
 	        
 	        lb $t2, ($t1)
 	        
 	        beq $t2, $t8, turnToBinary
 	        
 	        sll $t4, $t4, 4
 	        
 	        j Arg2Loop	
 	        
 	                
 	                        
        turnToBinary:
        
               
               and $t5, $t3, 0x000000f0     #changing the first argument from decimal to its true binary value and storing it in #t5
               
               srl $t5, $t5, 4
               
               mul $t5, $t5, 0xa
               
               and $t6, $t3, 0x0000000f
               
               add $t5, $t5, $t6
               
               
               and $t7, $t4, 0x000000f0    #changing the second argument from decimal to its true binary value and storing it in $t7
               
               srl $t7, $t7, 4
               
               mul $t7, $t7, 0xa
               
               and $t6, $t4, 0x0000000f
               
               add $t7, $t7, $t6
               
               
       Arg1NegCheck:
        
               lw $t1, ($a1)
               
               lb $t2, 0($t1)
               
               beq $t2, $t9, Arg12sComplement
               
               bne $t2, $t9, LoadArg1
               
        LoadArg1:
               
               bgt $t5, 0x0000003f, ExceptionHandler
                 
               or $s1, $t5, 0x00000000
               
               j Arg2NegCheck
               
        Arg12sComplement:
               
               li $t6, 0xffffffff
               
               xor $t5, $t5, $t6
               
               add $t5, $t5, 1
               
               blt $t5, 0xffffffc0, ExceptionHandler
               
               or $s1, $t5, $zero
               
               j Arg2NegCheck      
               
        Arg2NegCheck:  
        
             lw $t1, 4($a1)
             
             lb $t2, 0($t1)
             
             beq $t2, $t9, Arg22sComplement
             
             bne $t2, $t9, LoadArg2
             
         LoadArg2:
         
             bgt $t7, 0x0000003f, ExceptionHandler
         
             or $s2, $t7, 0x00000000
             
             j Sum
             
         Arg22sComplement:
         
             li $t6, 0xffffffff
               
             xor $t7, $t7, $t6
               
             add $t7, $t7, 1
             
             blt $t7, 0xffffffc0, ExceptionHandler
               
             or $s2, $t7, $zero
             
             j Sum
         
                             
               
         Sum:
              
               add $s0, $s1, $s2            #sum is now in $s0 in binary form
               
               blt $s0, $zero, NegGetValues #in the event that the sum is negative, this jumps to the negative get Values
                                            # which returns the 2's complement sum to its positive counterpart before carrying out any
                                            #necessary subsequent operations.
               div $s3, $s0, 10
               
               li $s4, 1
               
               bgtz $s3, PosOrderLoop      #if the sum is positive, but more than 1 digit long, this branch to the getOrder block
               
               add $s5, $s0, 48            #this block will execute if you have a positive single digit sum.
               
               la $a0, DecimalSum
               
               li $v0, 4
               
               syscall
               
               la $a0, ($s5)
               
               li $v0, 11
               
               syscall
               
               j nlPrint
               
               PosOrderLoop:
               
                       beq $s3, $t8, PosPrintValues #s4 will hold the number of digits in your sum (order + 1)
               	       
               	       div $s3, $s3, 10          
               
                       add $s4, $s4, 1
                       
                       j PosOrderLoop
                       
                       
        NegGetValues:       
               
               sub $s3, $s0, 1
               
               li $s4, 0xffffffff
               
               xor $s3, $s3, $s4            #The positive counterpart of your sum is now stored in $s3
               
               div $s4, $s3, 10
               
               li $s5, 1 
               
               bgt $s4, $zero, NegOrderLoop #this will jump to the NegOrderLoop in the event you have a negative sum that is over 1
                                            #digit long.
               
               add $s3, $s3, 48             #this block will execute if you have a negative single digit sum.
               
               la $a0, DecimalSum
               
               li $v0, 4
               
               syscall
               
               la $a0, ($t9)
               
               li $v0, 11
               
               syscall
               
               la $a0, ($s3)
               
               syscall
               
               j nlPrint
               
               NegOrderLoop:
               
                    beq $s4, $t8, NegPrintValues #s3 will hold the number of digits in your sum (order + 1)
               	       
               	    div $s4, $s4, 10          
               
                    add $s5, $s5, 1             #s5 will hold the number of digits in your sum
                       
                    j NegOrderLoop
               
                       
               
           NegPrintValues:                      #$s3 is your sum (don't forget to print the 2d before you print the sum
                                                #s5 is the number of digits in your sum (the number of times your loop needs to iterate)
                         
                        la $t6, ($s3)           #$t6 is now your sum
                        
                        li $s7, 0
                        
                        la $a0, DecimalSum
                        
                        li $v0, 4
                        
                        syscall
                        
                        la $a0, ($t9)
                        
                        li $v0, 11
                        
                        syscall
                        
                        negPrintRoutine:
                        
                               beq $s5, 2, negTwoValsLoad
                        
                               beq $s5, 3, negThreeValsLoad
                               
                               
                               negTwoValsLoad:
                                            li $t0, 0xa
                                            
                                            li $t1, 0xa
                                            
                                            j negPrintLoop
                               
                               
                               negThreeValsLoad:
                        
                                            li $t0, 0x64
                               
                                            li $t1, 0xa
                                            
                                            j negPrintLoop
                               
                               negPrintLoop:
                                        
                                        beq $s7, $s5, nlPrint
                                        
                                        div $t2, $t6, $t0
                                        
                                        add $t2, $t2, 48
                                        
                                        la $a0, ($t2)
                                        
                                        syscall
                                        
                                        rem $t6, $t6, $t0
                                        
                                        div $t0, $t0, $t1
                                        
                                        add $s7, $s7, 1
                                        
                                        j negPrintLoop
                               
                               
               PosPrintValues:                         #s0 is your sum (don't need to print the negative sign)
                                                       #$s4 is the number of digits in your sum (the number of times your loop needs to iterate)
                        
                        la $t6, ($s0)                  #$t6 is now your sum
                        
                        li $s5, 0
                        
                        la $a0, DecimalSum
                        
                        li $v0, 4
                        
                        syscall
                        
                        li $v0, 11
                        
                        posPrintRoutine:
                        
                               beq $s4, 2, twoValsLoad
                        
                               beq $s4, 3, threeValsLoad
                               
                               twoValsLoad:
                                            li $t0, 0xa
                                            
                                            li $t1, 0xa
                                            
                                            j posPrintLoop
                               
                               
                               threeValsLoad:
                        
                                            li $t0, 0x64
                               
                                            li $t1, 0xa
                                            
                                            j posPrintLoop
                               
                               posPrintLoop:
                                        
                                        beq $s5, $s4, nlPrint
                                        
                                        div $t2, $t6, $t0
                                        
                                        add $t2, $t2, 48
                                        
                                        la $a0, ($t2)
                                        
                                        syscall
                                        
                                        rem $t6, $t6, $t0
                                        
                                        div $t0, $t0, $t1
                                        
                                        add $s5, $s5, 1
                                        
                                        j posPrintLoop
                               
                               nlPrint:
                               
                                       la $a0, newLine
                                       
                                       li $v0, 4
                                       
                                       syscall
                                       
                                       syscall
                                       
                                       j printBinaryRoutine
                                       
              printBinaryRoutine:
              
                     la $a0, twosComp
                     
                     li $v0, 4
                     
                     syscall
                     
                     li $t0, 0          #counter variable
                     
                     li $t1, 0x80000000 #mask variable
                     
                     printBinLoop:
                                 
                                 beq $t0, 32, printLastLine
                                 
                                 and $t2, $s0, $t1
                                 
                                 beq $t2, $t1, printOne
                                 
                                 bne $t2, $t1, printZero
                                 
                                 printOne:
                                 
                                         la $a0, 0x31
                                         
                                         li $v0, 11
                                         
                                         syscall
                                         
                                         j skipPrintZero
                                         
                                 printZero:
                                        
                                         la $a0, 0x30
                                         
                                         li $v0, 11
                                         
                                         syscall
                                         
                                  skipPrintZero:
                                  
                                  srl $t1, $t1, 1
                                  
                                  add $t0, $t0 1
                                  
                                  j printBinLoop
                                  
                                   
                     
               printLastLine:
               
                            la $a0, newLine
                            
                            li $v0, 4
                            
                            syscall
                            
                            syscall
                            
                            j printMorse
                            
               printMorse:
                
                         li $t6, 0x00000000
                         
                         la $t0, ($s0) #$t0 is now your sum.
                         
                         li $v0, 4
                         
                         la $a0, morsePrompt
                         
                         syscall
                         
                         blt $t0, 0, negHandler
                         
                         beq $t0, 0, morseContinue
                         
                         bgt $t0, 0, morseContinue
                         
                         negHandler:
                         
                                   la $a0, negSign
                                   
                                   syscall
                                   
                                   mul $t0, $t0, -1
                                   
                                   j morseContinue
                                   
                        morseContinue:
                                     li $s5, 0x0
                                     
                                     la $t1, ($t0)
                                     restoreOrderLoop:
                                     
                                            div $t1, $t1, 10          
               
                                            add $s5, $s5, 1
               
                                            beq $t1, $t8, extractVals 
               	       
               	                            j restoreOrderLoop
                                     
                                     
                                     extractVals:
                                     
                                                li $t5, 0 #counter variable
                                     
                                                li $v0, 1
                                     
                                                #la $t0, ($s0)
                                     
                                                beq $s5, 3, loadHun
                                                
                                                beq $s5, 2, loadTen
                                                
                                                beq $s5, 1, loadOne
                                                
                                                loadHun:
                                                      
                                                       li $t1, 0x64
                                                       
                                                       li $t2, 0xa
                                                       
                                                       j extractValsLoop
                                                       
                                                loadTen:
                                                
                                                       
                                                
                                                       li $t1, 0xa
                                                       
                                                       li $t2, 0xa
                                                       
                                                       j extractValsLoop
                                                       
                                                loadOne:
                                                
                                                       li $t1, 0x1
                                                       
                                                       li $t2, 0x1
                                                       
                                                       j extractValsLoop
                                     
                                                extractValsLoop:
                                                               
                                                               beq $t5, $s5, exit
                                                               
                                                               div $t3, $t0, $t1
                                                               
                                                              
                                                               j outputMorse #your value to be printed in Morse code is in $t3
                                                               
                                                               outputMorseReturn:
                                                               
                                                               rem $t0, $t0, $t1
                                                               
                                                               div $t1, $t1, $t2
                                                               
                                                               add $t5, $t5, 1
                                                                
                                                               j extractValsLoop
                                                               
                                             outputMorse:
                                             
                                                        li $t6, 0 #counter variable
                                                        
                                                        li $v0, 11
                                             
                                                        beq $t3, 0, allDashes
                                                        
                                                        beq $t3, 5, allDots
                                                        
                                                        j morseLoops
                                                        
                                                        allDashes:
                                                        
                                                                 beq $t6, 5, printSpace
                                                                 
                                                                 li $a0, 0x2d
                                                                 
                                                                 syscall
                                                                 
                                                                 add $t6, $t6, 1
                                                                 
                                                                 j allDashes
                                                                 
                                                        allDots:
                                                        
                                                               beq $t6, 5, printSpace
                                                               
                                                               li $a0, 0x2e
                                                               
                                                               syscall
                                                               
                                                               add $t6, $t6, 1
                                                               
                                                               j allDots
                                                               
                                                        morseLoops:
                                                        
                                                                  li $t6, 0x00000000
                                                                  
                                                                  blt $t3, 5, lessThanFive
                                                                  
                                                                  li $t8, 0x5
                                                                  
                                                                  sub $t9, $t8, $t3 #for your greaterThanFive loop 
                                                                  
                                                                  mul $t9, $t9, -1 #$t9 now holds the conditional value necessary to
                                                                                   #correctly execute the greaterThanFive loop.
                                                                  
                                                                  
                                                                  bgt $t3, 5, greaterThanFive
                                                                  
                                                                  lessThanFive:
                                                                  
                                                                              beq $t6, 5, printSpace
                                                                  
                                                                              blt $t6, $t3, printDot
                                                                              
                                                                              beq $t6, $t3, lessThanFiveContinue
                                                                              
                                                                              bgt $t6, $t3, lessThanFiveContinue
                                                                              
                                                                              printDot:
                                                                              
                                                                                      li $v0, 11
                                                                                      
                                                                                      li $a0, 0x2e
                                                                                      
                                                                                      syscall
                                                                                      
                                                                                      add $t6, $t6, 1
                                                                                      
                                                                                      j lessThanFive
                                                                             
                                                                             lessThanFiveContinue:
                                                                             
                                                                                      li $v0, 11
                                                                                      
                                                                                      li $a0, 0x2d
                                                                                      
                                                                                      syscall
                                                                                      
                                                                                      add $t6, $t6, 1
                                                                                      
                                                                                      j lessThanFive
                                                            
                                                              greaterThanFive:
                                                              
                                                                              beq $t6, 5, printSpace
                                                                  
                                                                              blt $t6, $t9, printDash
                                                                              
                                                                              beq $t6, $t9, greaterThanFiveContinue
                                                                              
                                                                              bgt $t6, $t9, greaterThanFiveContinue
                                                                              
                                                                              printDash:
                                                                              
                                                                                      li $v0, 11
                                                                                      
                                                                                      li $a0, 0x2d
                                                                                      
                                                                                      syscall
                                                                                      
                                                                                      add $t6, $t6, 1
                                                                                      
                                                                                      j greaterThanFive
                                                                             
                                                                             greaterThanFiveContinue:
                                                                             
                                                                                      li $v0, 11
                                                                                      
                                                                                      li $a0, 0x2e
                                                                                      
                                                                                      syscall
                                                                                      
                                                                                      add $t6, $t6, 1
                                                                                      
                                                                                      j greaterThanFive
                                     printSpace:
                                                        
                                             li $v0, 11
                                                                  
                                             la $a0, 0x20
                                                                  
                                             syscall
                                                                  
                                             j outputMorseReturn                                          
                                      
                                                                 
                                                                                            
                                    exit:
                                    
                                        li $v0, 4
                                        
                                        la $a0, newLine
                                        
                                        syscall
	
		                        li $v0, 10
		
		                        syscall  
                                                                                                                                                
                                                                 
                                                                 
                                                                     
                                                               
                                                           
                                                               
                                                               
                                                               
                                                               
                                     
                                            
                                                         
                                                         
                                                                      
                                                         
                                                         
                                     
                                                                                                           
                                                               
                                                               
                                                       
                                                               
                                                               
                                        
                                                              
                                                  
                                                 
                                                   
                                                            
                                                   
                                
                                                   
                                                   
                                                   
                                                   
                                                   
                                                          
                                     
                                                   
                                     
                                     
                                     
                                     
                                     
                                     
                                     
                                     
                                   
                        
                                   
                                   
                                   
                         
                         
                         
               
