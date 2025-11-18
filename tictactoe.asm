.stack 100h
.data
    ; Game board and display
    board db ' ',' ',' ',' ',' ',' ',' ',' ',' '
    num_board db '1','2','3','4','5','6','7','8','9'

    ; Messages and prompts
    title_msg db "Assembly Tic Tac Toe", 0Dh, 0Ah, "$"
    subtitle_msg db "Made by AAA (Aryan, Ajwad and Amreen)", 0Dh, 0Ah, 0Dh, 0Ah, "$"
    press_space db "Press SPACE to continue...", 0Dh, 0Ah, "$"
    p1_name_prompt db "Enter Player 1 name: $"
    p2_name_prompt db 0Dh, 0Ah, "Enter Player 2 name: $"
    timer_prompt db 0Dh, 0Ah, "Choose timer per move: 1=10s, 2=20s, 3=40s: $"
    toss_msg db 0Dh, 0Ah, "Coin toss... Press any key for result.", 0Dh, 0Ah, "$"
    x_starts db " wins the toss and starts as X!", 0Dh, 0Ah, "$"
    player_info db " (X) vs ", "$"
    player_info2 db " (O)", 0Dh, 0Ah, "$"
    p_turn_msg db "'s turn ($). Position (1-9): $"
    invalid_msg db 0Dh, 0Ah, "Invalid move! Try again: $"
    win_msg db " WINS! Congratulations!", 0Dh, 0Ah, "$"
    draw_msg db "IT'S A DRAW! Good game both players!", 0Dh, 0Ah, "$"
    timer_msg db "Time left: ?? seconds $"
    times_up db 0Dh, 0Ah, "Time's up! Next player's turn.", 0Dh, 0Ah, "$"
    replay_msg db 0Dh, 0Ah, "Press R for rematch or Q to quit: $"
    horz_line db "---+---+---        ---+---+---", 0Dh, 0Ah, "$"
    history_msg db 0Dh, 0Ah, "MOVE HISTORY:", 0Dh, 0Ah, "============", 0Dh, 0Ah, "$"
    view_history db 0Dh, 0Ah, "Press H to view history, any other key to continue.", 0Dh, 0Ah, "$"
    score_header db 0Dh, 0Ah, "CURRENT SCORES:", 0Dh, 0Ah, "==============", 0Dh, 0Ah, "$"
    score_sep db ": $"
    newline db 0Dh, 0Ah, "$"
    game_result_header db 0Dh, 0Ah, "GAME OVER!", 0Dh, 0Ah, "=========", 0Dh, 0Ah, "$"

    ; History storage
    history_players db 9 dup(0)
    history_marks db 9 dup(0)
    history_positions db 9 dup(0)

    ; Game state
    current_player db 1
    game_over db 0
    p1_score db 0
    p2_score db 0
    timer_limit db 10
    timer_count db 10
    current_mark db 'X'
    winner_player db 0
    p1_name db 20 dup('$')
    p2_name db 20 dup('$')
    toss_winner db 1
    history_count db 0
    last_position db 0

.code
main proc
    mov ax, @data
    mov ds, ax
    
start_game:
    call title_screen
    call get_player_names
    call coin_toss
    call reset_game
    
game_loop:
    call clear_screen
    call display_score
    call display_boards
    call check_history_option
    call check_game_over
    cmp [game_over], 1
    je game_end
    call player_turn
    jmp game_loop
    
game_end:
    call display_result
    call ask_replay
    cmp al, 1
    je start_game
    
    mov ah, 4Ch
    int 21h
main endp

; ----------- Aryan Rahman Mugdha (22101111) ----------------
; Features 1 and 2: Player turns and Coin toss

; Show title screen
title_screen proc
    call clear_screen
    mov ah, 9
    mov dx, offset title_msg
    int 21h
    mov dx, offset subtitle_msg
    int 21h
    mov dx, offset press_space
    int 21h
    
wait_space:
    mov ah, 0
    int 16h
    cmp al, ' '
    jne wait_space
    ret
title_screen endp

;player names and timer 
get_player_names proc
    call clear_screen
    
    ;Player 1 
    mov ah, 9
    mov dx, offset p1_name_prompt
    int 21h
    mov ah, 0Ah
    mov dx, offset p1_name
    mov byte ptr [p1_name], 18
    int 21h
    mov si, offset p1_name + 2
    mov cl, [p1_name + 1]
    mov ch, 0
    add si, cx
    mov byte ptr [si], '$'
    
    ;Player 2
    mov ah, 9
    mov dx, offset p2_name_prompt
    int 21h
    mov ah, 0Ah
    mov dx, offset p2_name
    mov byte ptr [p2_name], 18
    int 21h
    mov si, offset p2_name + 2
    mov cl, [p2_name + 1]
    mov ch, 0
    add si, cx
    mov byte ptr [si], '$'
    
    ;timer choice
timer_input:
    mov ah, 9
    mov dx, offset timer_prompt
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 1
    je set_10
    cmp al, 2
    je set_20
    cmp al, 3
    je set_40
    jmp timer_input
    
set_10:
    mov [timer_limit], 10
    jmp done_timer
set_20:
    mov [timer_limit], 20
    jmp done_timer
set_40:
    mov [timer_limit], 40
done_timer:
    ret
get_player_names endp

; Coin toss
coin_toss proc
    mov ah, 9
    mov dx, offset toss_msg
    int 21h
    mov ah, 0
    int 16h
    mov ah, 0
    int 1Ah
    mov ax, dx
    and ax, 1
    inc ax
    mov [toss_winner], al
    mov ah, 9
    mov dx, offset newline
    int 21h
    cmp al, 1
    je toss_p1
    mov dx, offset p2_name + 2
    jmp print_toss
toss_p1:
    mov dx, offset p1_name + 2
print_toss:
    mov ah, 9
    int 21h
    mov dx, offset x_starts
    int 21h
    mov cx, 1Eh
    mov dx, 8480h
    mov ah, 86h
    int 15h
    ret
coin_toss endp

player_turn proc
    ; Display whose turn
    mov ah, 9
    mov dx, offset newline
    int 21h
    cmp [current_player], 1
    je p1_turn_display
    mov dx, offset p2_name + 2
    jmp show_turn_name
p1_turn_display:
    mov dx, offset p1_name + 2
show_turn_name:
    mov ah, 9
    int 21h
    mov al, [current_mark]
    mov [p_turn_msg + 9], al
    mov dx, offset p_turn_msg
    int 21h
    
    ; Initializing timer
    mov al, [timer_limit]
    mov [timer_count], al
    
timer_loop:
    ; Display timer
    mov ah, 2
    mov bh, 0
    mov dh, 15
    mov dl, 0
    int 10h
    mov ax, 0
    mov al, [timer_count]
    cmp al, 10
    jl single_digit_timer
    mov bl, 10
    div bl
    add al, '0'
    add ah, '0'
    mov [timer_msg + 11], al
    mov [timer_msg + 12], ah
    jmp show_timer
    
single_digit_timer:
    mov [timer_msg + 11], '0'
    add al, '0'
    mov [timer_msg + 12], al
    
show_timer:
    mov ah, 9
    mov dx, offset timer_msg
    int 21h
    mov ah, 1
    int 16h
    jnz get_input
    mov cx, 0Fh
    mov dx, 4240h
    mov ah, 86h
    int 15h
    dec [timer_count]
    jz time_expired
    jmp timer_loop
    
time_expired:
    mov ah, 9
    mov dx, offset times_up
    int 21h
    mov cx, 1Eh
    mov dx, 8480h
    mov ah, 86h
    int 15h
    call switch_player
    ret
    
get_input:
    mov ah, 0
    int 16h
    sub al, '0'
    cmp al, 1
    jl invalid_input
    cmp al, 9
    jg invalid_input
    mov bx, 0
    mov bl, al
    dec bl
    mov cl, [board + bx]
    cmp cl, ' '
    jne invalid_input
    mov cl, [current_mark]
    mov [board + bx], cl
    mov [last_position], al
    call record_move
    call switch_player
    ret
    
invalid_input:
    mov ah, 9
    mov dx, offset invalid_msg
    int 21h
    mov ah, 1
    int 21h
    jmp get_input
player_turn endp


; Switch player
switch_player proc
    
    cmp [current_player], 1
    je set_p2
    mov [current_player], 1
    jmp short set_mark  
set_p2:
    mov [current_player], 2
    
    ; Set mark by toss
set_mark:
    mov al, [current_player]
    cmp al, [toss_winner]
    je set_x_mark
    mov [current_mark], 'O'
    ret
set_x_mark:
    mov [current_mark], 'X'
    ret
switch_player endp

; Display number and game grids
display_boards proc
    ; X/O 
    mov ah, 9
    mov dx, offset newline
    int 21h
    cmp [toss_winner], 1
    je p1_is_x
    mov dx, offset p2_name + 2
    mov ah, 9
    int 21h
    mov dx, offset player_info
    int 21h
    mov dx, offset p1_name + 2
    int 21h
    mov dx, offset player_info2
    int 21h
    jmp show_grids
    
p1_is_x:
    mov dx, offset p1_name + 2
    mov ah, 9
    int 21h
    mov dx, offset player_info
    int 21h
    mov dx, offset p2_name + 2
    int 21h
    mov dx, offset player_info2
    int 21h
    
show_grids:
    mov ah, 9
    mov dx, offset newline
    int 21h
    
    ; Grid headers
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'P'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 's'
    int 21h
    mov dl, 'i'
    int 21h
    mov dl, 't'
    int 21h
    mov dl, 'i'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 'n'
    int 21h
    mov dl, 's'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'G'
    int 21h
    mov dl, 'a'
    int 21h
    mov dl, 'm'
    int 21h
    mov dl, 'e'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'B'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 'a'
    int 21h
    mov dl, 'r'
    int 21h
    mov dl, 'd'
    int 21h
    
    mov ah, 9
    mov dx, offset newline
    int 21h
    
    ; Row 1
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+0]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+1]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+2]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+0]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+1]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+2]
    int 21h
    mov dl, ' '
    int 21h
    
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov dx, offset horz_line
    int 21h
    
    ; Row 2
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+3]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+4]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+5]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+3]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+4]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+5]
    int 21h
    mov dl, ' '
    int 21h
    
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov dx, offset horz_line
    int 21h
    
    ; Row 3
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+6]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+7]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [num_board+8]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+6]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+7]
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '|'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [board+8]
    int 21h
    mov dl, ' '
    int 21h
    
    ret
display_boards endp

; ------- Ajwad Ahnaf (21201336) ---------
; Features 3 and 4: Winner checking and Draw detection

; Check game over (win or draw)
check_game_over proc
    ; Check rows
    mov cx, 3
    mov si, 0
check_rows:
    mov al, [board+si]
    cmp al, ' '
    je next_row
    cmp al, [board+si+1]
    jne next_row
    cmp al, [board+si+2]
    jne next_row
    call set_winner
    ret
next_row:
    add si, 3
    loop check_rows
    
    ; Check columns
    mov cx, 3
    mov si, 0
check_cols:
    mov al, [board+si]
    cmp al, ' '
    je next_col
    cmp al, [board+si+3]
    jne next_col
    cmp al, [board+si+6]
    jne next_col
    call set_winner
    ret
next_col:
    inc si
    loop check_cols
    
    ; Check diagonals
    mov al, [board+0]
    cmp al, ' '
    je check_diag2
    cmp al, [board+4]
    jne check_diag2
    cmp al, [board+8]
    jne check_diag2
    call set_winner
    ret
    
check_diag2:
    mov al, [board+2]
    cmp al, ' '
    je check_draw
    cmp al, [board+4]
    jne check_draw
    cmp al, [board+6]
    jne check_draw
    call set_winner
    ret
    
    ; Check draw
check_draw:
    mov cx, 9
    mov si, 0
check_full:
    cmp [board+si], ' '
    je not_full
    inc si
    loop check_full
    mov [game_over], 1
    mov [winner_player], 0
    ret
    
not_full:
    ret
check_game_over endp

; Set winner  
set_winner proc
    mov [game_over], 1
    ;get the previous player 
    cmp [current_player], 1
    je winner_was_p2
    mov [winner_player], 1
    ret
winner_was_p2:
    mov [winner_player], 2
    ret
set_winner endp

; Display game result
display_result proc
    call clear_screen
    call display_boards
    mov ah, 9
    mov dx, offset game_result_header
    int 21h
    cmp [winner_player], 0
    je show_draw
    mov ah, 2
    mov dl, '*'
    int 21h
    mov dl, '*'
    int 21h
    mov dl, '*'
    int 21h
    mov dl, ' '
    int 21h
    cmp [winner_player], 1
    je p1_won
    mov ah, 9
    mov dx, offset p2_name + 2
    int 21h
    mov dx, offset win_msg
    int 21h
    inc [p2_score]
    jmp show_celebration
    
p1_won:
    mov ah, 9
    mov dx, offset p1_name + 2
    int 21h
    mov dx, offset win_msg
    int 21h
    inc [p1_score]
    jmp show_celebration
    
show_draw:
    mov ah, 2
    mov dl, '='
    int 21h
    mov dl, '='
    int 21h
    mov dl, '='
    int 21h
    mov dl, ' '
    int 21h
    mov ah, 9
    mov dx, offset draw_msg
    int 21h
    jmp result_done
    
show_celebration:
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, '*'
    int 21h
    mov dl, '*'
    int 21h
    mov dl, '*'
    int 21h
    mov ah, 9
    mov dx, offset newline
    int 21h
    
result_done:
    call display_score
    call check_history_option
    ret
display_result endp

; Ask for replay
ask_replay proc
    mov ah, 9
    mov dx, offset replay_msg
    int 21h
    
wait_key:
    mov ah, 0
    int 16h
    cmp al, 'R'
    je replay_yes
    cmp al, 'r'
    je replay_yes
    cmp al, 'Q'
    je quit_game
    cmp al, 'q'
    je quit_game
    jmp wait_key
    
replay_yes:
    mov al, 1
    ret
    
quit_game:
    call clear_screen
    mov ah, 2
    mov dl, 'T'
    int 21h
    mov dl, 'h'
    int 21h
    mov dl, 'a'
    int 21h
    mov dl, 'n'
    int 21h
    mov dl, 'k'
    int 21h
    mov dl, 's'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'f'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 'r'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'p'
    int 21h
    mov dl, 'l'
    int 21h
    mov dl, 'a'
    int 21h
    mov dl, 'y'
    int 21h
    mov dl, 'i'
    int 21h
    mov dl, 'n'
    int 21h
    mov dl, 'g'
    int 21h
    mov dl, '!'
    int 21h
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov al, 0
    ret
ask_replay endp

; -------- Amreen Hassan (20201211) ---------
; Features 5 and 6: Move validation and History/Scores

; Handle history viewing
check_history_option proc
    mov ah, 9
    mov dx, offset view_history
    int 21h
    mov ah, 0
    int 16h
    cmp al, 'H'
    je show_history
    cmp al, 'h'
    je show_history
    ret
    
show_history:
    call display_history
    ret
check_history_option endp

; Reset game
reset_game proc
    mov cx, 9
    mov si, 0
init_board:
    mov [board+si], ' '
    inc si
    loop init_board
    mov al, [toss_winner]
    mov [current_player], al
    mov [game_over], 0
    mov [current_mark], 'X'
    mov [winner_player], 0
    mov [history_count], 0
    mov cx, 9
    mov si, 0
clear_history:
    mov [history_players+si], 0
    mov [history_marks+si], 0
    mov [history_positions+si], 0
    inc si
    loop clear_history
    mov al, [timer_limit]
    mov [timer_count], al
    ret
reset_game endp

; Record move
record_move proc
    mov al, [history_count]
    mov ah, 0
    mov si, ax
    mov al, [current_player]
    mov [history_players+si], al
    mov al, [current_mark]
    mov [history_marks+si], al
    mov al, [last_position]
    add al, '0'
    mov [history_positions+si], al
    inc [history_count]
    ret
record_move endp

; Display score
display_score proc
    mov ah, 9
    mov dx, offset score_header
    int 21h
    mov dx, offset p1_name + 2
    int 21h
    mov dx, offset score_sep
    int 21h
    mov ah, 2
    mov dl, [p1_score]
    add dl, '0'
    int 21h
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov dx, offset p2_name + 2
    int 21h
    mov dx, offset score_sep
    int 21h
    mov ah, 2
    mov dl, [p2_score]
    add dl, '0'
    int 21h
    mov ah, 9
    mov dx, offset newline
    int 21h
    ret
display_score endp

; Display move history
display_history proc
    call clear_screen
    mov ah, 9
    mov dx, offset history_msg
    int 21h
    mov cl, [history_count]
    cmp cl, 0
    je no_history
    mov ch, 0
    mov si, 0
    mov bl, 1
    
history_loop:
    mov ah, 2
    mov dl, 'M'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 'v'
    int 21h
    mov dl, 'e'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, bl
    add dl, '0'
    int 21h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov al, [history_players+si]
    cmp al, 1
    je hist_p1
    mov ah, 9
    mov dx, offset p2_name + 2
    jmp show_move_info
hist_p1:
    mov ah, 9
    mov dx, offset p1_name + 2
    
show_move_info:
    int 21h
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, '('
    int 21h
    mov dl, [history_marks+si]
    int 21h
    mov dl, ')'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, '-'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'P'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 's'
    int 21h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, [history_positions+si]
    int 21h
    mov ah, 9
    mov dx, offset newline
    int 21h
    inc si
    inc bl
    loop history_loop
    jmp history_done
    
no_history:
    mov ah, 2
    mov dl, 'N'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'm'
    int 21h
    mov dl, 'o'
    int 21h
    mov dl, 'v'
    int 21h
    mov dl, 'e'
    int 21h
    mov dl, 's'
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 'y'
    int 21h
    mov dl, 'e'
    int 21h
    mov dl, 't'
    int 21h
    mov dl, '.'
    int 21h
    
history_done:
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov dx, offset press_space
    int 21h
    
    ; Wait for space key to continue
wait_space_history:
    mov ah, 0
    int 16h
    cmp al, ' '
    jne wait_space_history
    ret
display_history endp

; Clear screen
clear_screen proc
    mov ah, 0
    mov al, 3
    int 10h
    ret
clear_screen endp

end main