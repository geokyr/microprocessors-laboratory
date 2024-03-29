; AVR GCC compiler is used so there are a few changes on the code, like
; high -> hi8, low -> lo8 and .include "m16def.inc" -> #include <avr/io.h>

; following lines are needed to use the IN/OUT ports
#define _SFR_ASM_COMPAT 1 
#define __SFR_OFFSET 0
#include <avr/io.h>

; global declaration of functions that are used in the c program
.global lcd_data_sim
.global lcd_init_sim

write_2_nibbles_sim:
	push r24                    ; τμήμα κώδικα που προστίθεται για τη σωστή
	push r25                    ; λειτουργία του προγράμματος απομακρυσμένης
	ldi r24 ,lo8(6000)          ; πρόσβασης
    ldi r25 ,hi8(6000)
	rcall wait_usec
	pop r25
	pop r24                     ; τέλος τμήμα κώδικα
	push r24                    ; στέλνει τα 4 MSB
	in r25, PIND                ; διαβάζονται τα 4 LSB και τα ξαναστέλνουμε
	andi r25, 0x0f              ; για να μην χαλάσουμε την όποια προηγούμενη κατάσταση
	andi r24, 0xf0              ; απομονώνονται τα 4 MSB και
	add r24, r25                ; συνδυάζονται με τα προϋπάρχοντα 4 LSB
	out PORTD, r24              ; και δίνονται στην έξοδο
	sbi PORTD, PD3              ; δημιουργείται παλμός Enable στον ακροδέκτη PD3
	cbi PORTD, PD3              ; PD3=1 και μετά PD3=0
	push r24                    ; τμήμα κώδικα που προστίθεται για τη σωστή
	push r25                    ; λειτουργία του προγράμματος απομακρυσμένης
	ldi r24 ,lo8(6000)          ; πρόσβασης
    ldi r25 ,hi8(6000)
	rcall wait_usec
	pop r25
	pop r24                     ; τέλος τμήμα κώδικα
	pop r24                     ; στέλνει τα 4 LSB. Ανακτάται το byte.
	swap r24                    ; εναλλάσσονται τα 4 MSB με τα 4 LSB
	andi r24 ,0xf0              ; που με την σειρά τους αποστέλλονται
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3              ; Νέος παλμός Enable
	cbi PORTD, PD3
	ret

lcd_data_sim:
	push r24
	push r25
	sbi PORTD,PD2
	rcall write_2_nibbles_sim
	ldi r24,43
	ldi r25,0
	rcall wait_usec
	pop r25
	pop r24
	ret

lcd_command_sim:
	push r24                    ; αποθήκευσε τους καταχωρητές r25:r24 γιατί τους
	push r25                    ; αλλάζουμε μέσα στη ρουτίνα
	cbi PORTD, PD2              ; επιλογή του καταχωρητή εντολών (PD2=0)
	rcall write_2_nibbles_sim   ; αποστολή της εντολής και αναμονή 39μsec
	ldi r24, 39                 ; για την ολοκλήρωση της εκτέλεσης της από τον ελεγκτή της lcd.
	ldi r25, 0                  ; ΣΗΜ.: υπάρχουν δύο εντολές, οι clear display και return home,
	rcall wait_usec             ; που απαιτούν σημαντικά μεγαλύτερο χρονικό διάστημα.
	pop r25                     ; επανάφερε τους καταχωρητές r25:r24
	pop r24
	ret 

lcd_init_sim:
	push r24                    ; αποθήκευσε τους καταχωρητές r25:r24 γιατί τους
	push r25                    ; αλλάζουμε μέσα στη ρουτίνα

	ldi r24, 40                 ; Όταν ο ελεγκτής της lcd τροφοδοτείται με
	ldi r25, 0                  ; ρεύμα εκτελεί την δική του αρχικοποίηση.
	rcall wait_msec             ; Αναμονή 40 msec μέχρι αυτή να ολοκληρωθεί.
	ldi r24, 0x30               ; εντολή μετάβασης σε 8 bit mode
	out PORTD, r24              ; επειδή δεν μπορούμε να είμαστε βέβαιοι
	sbi PORTD, PD3              ; για τη διαμόρφωση εισόδου του ελεγκτή
	cbi PORTD, PD3              ; της οθόνης, η εντολή αποστέλλεται δύο φορές
	ldi r24, 39
	ldi r25, 0                  ; εάν ο ελεγκτής της οθόνης βρίσκεται σε 8-bit mode
	rcall wait_usec             ; δεν θα συμβεί τίποτα, αλλά αν ο ελεγκτής έχει διαμόρφωση
	                            ; εισόδου 4 bit θα μεταβεί σε διαμόρφωση 8 bit
	push r24                    ; τμήμα κώδικα που προστίθεται για τη σωστή
	push r25                    ; λειτουργία του προγράμματος απομακρυσμένης
	ldi r24,lo8(1000)           ; πρόσβασης
    ldi r25,hi8(1000)
	rcall wait_usec
	pop r25
	pop r24                     ; τέλος τμήμα κώδικα
	ldi r24, 0x30
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec 
	push r24                    ; τμήμα κώδικα που προστίθεται για τη σωστή
	push r25                    ; λειτουργία του προγράμματος απομακρυσμένης
	ldi r24 ,lo8(1000)          ; πρόσβασης
    ldi r25 ,hi8(1000)
	rcall wait_usec
	pop r25
	pop r24                     ; τέλος τμήμα κώδικα
	ldi r24,0x20                ; αλλαγή σε 4-bit mode
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	push r24                    ; τμήμα κώδικα που προστίθεται για τη σωστή
	push r25                    ; λειτουργία του προγράμματος απομακρυσμένης
	ldi r24 ,lo8(1000)          ; πρόσβασης
    ldi r25 ,hi8(1000)
	rcall wait_usec
	pop r25
	pop r24                     ; τέλος τμήμα κώδικα
	ldi r24,0x28                ; επιλογή χαρακτήρων μεγέθους 5x8 κουκίδων
	rcall lcd_command_sim       ; και εμφάνιση δύο γραμμών στην οθόνη
	ldi r24,0x0c                ; ενεργοποίηση της οθόνης, απόκρυψη του κέρσορα
	rcall lcd_command_sim
	ldi r24,0x01                ; καθαρισμός της οθόνης
	rcall lcd_command_sim
	ldi r24, lo8(1530)
    ldi r25, hi8(1530)
	rcall wait_usec
	ldi r24 ,0x06               ; ενεργοποίηση αυτόματης αύξησης κατά 1 της διεύθυνσης
	rcall lcd_command_sim       ; που είναι αποθηκευμένη στον μετρητή διευθύνσεων και
	                            ; απενεργοποίηση της ολίσθησης ολόκληρης της οθόνης
	pop r25                     ; επανάφερε τους καταχωρητές r25:r24
	pop r24
	ret

wait_msec:
    push r24                    ; 2 κύκλοι (0.250 μsec)
    push r25                    ; 2 κύκλοι
    ldi r24 , lo8(998)          ; φόρτωσε τον καταχ. r25:r24 με 998 (1 κύκλος - 0.125 μsec)
    ldi r25 , hi8(998)         ; 1 κύκλος (0.125 μsec)
    rcall wait_usec             ; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec
    pop r25                     ; 2 κύκλοι (0.250 μsec)
    pop r24                     ; 2 κύκλοι
    sbiw r24 , 1                ; 2 κύκλοι
    brne wait_msec              ; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret                         ; 4 κύκλοι (0.500 μsec)

wait_usec:
    sbiw r24 ,1                 ; 2 κύκλοι (0.250 μsec)
    nop                         ; 1 κύκλος (0.125 μsec)
    nop                         ; 1 κύκλος (0.125 μsec)
    nop                         ; 1 κύκλος (0.125 μsec)
    nop                         ; 1 κύκλος (0.125 μsec)
    brne wait_usec              ; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret                         ; 4 κύκλοι (0.500 μsec)