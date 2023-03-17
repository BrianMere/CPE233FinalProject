
// Sample functionality (as provided by Hummel :)

// int sum(int x, int y)
// {
// 	return x+y;
// }
// void main()
// {
// 	int total=0;
// 	for(int i=0;i<100;i++)
// 		sum(total,i);
// }

// #include <tgmath.h>
#include <math.h>
#include <string.h>
#include <ctype.h>

// Postfix stuff

#define MAX_SIZE 100
#define PI 3.1415927f
#define E 2.7182813f

typedef struct {
    char stack[MAX_SIZE];
    int top;
} Stack;

typedef struct {
	int x;
	int y;
} Point;

// CONSTANTS

// Memory Constants
#define MMIO 0x11000000
#define KEYBOARD 0x100
#define VG_ADDR 0x11000120
#define VG_COLOR 0x11000140

volatile int* const write_data_ptr = (int *) VG_COLOR;   // select color address (wd)
volatile int* const write_address_ptr = (int *) VG_ADDR; // select register address, and write pixel_address

register int s6 asm("%s6");
char scan_code;
int is_shift;

// Preprocessor...

// For plotting

volatile void draw_dot(Point p, int rgb);
void draw_rect(Point p1, Point p2, int rgb);
void draw_background(int rgb);
void draw_character(Point p, int c, int rgb);

// Functions
float execute_real_function(float x, char function[]);

// String manipulations
void remove_spaces(char[]);

void ISR();

// MISC:
void push(Stack *s, char c);
char pop(Stack *s);
int precedence(char op);
void infixToPostfix(char *infix, char *postfix);
int isOperator(char input);
float doOperator(char operator, float operand1, float operand2);
int getInc(char operator);

char parse_scan_code();

// Begin MAIN!
// START_X: what value is x on the LHS of the screen. I indicates the desired increment. 
#define START_X	-4.0f
#define X_I 0.1f

#define START_Y -2.0f
#define Y_I 0.1f

// Screen sizes
#define COLUMN_SIZE 80
#define ROW_SIZE 50
#define EDITOR_ROWS 60 - ROW_SIZE

// Default Colors:
// usually for writing hexadecimal values we use unsigned char a = 0x64; or int b = 0xFAFA
// 3 bits red, 3b green, 2b blue
#define COL_RED 0xE0
#define COL_GREEN 0x1C
#define COL_BLUE 0x03
#define COL_BLACK 0x00
#define COL_WHITE 0xFF
#define COL_YELLOW 0xFC
#define COL_CYAN 0x1F
#define COL_MAGENTA 0xE3

#define BACKSPACE 8

// Character definitions
#define CHAR_PLUS   0x000004e4
#define CHAR_MINUS  0x000000e0
#define CHAR_MULT   0x00000a4a
#define CHAR_DIV    0x00002448
#define CHAR_POW    0x00004a00

#define CHAR_S      0x0000f8f7
#define CHAR_Q      0x0000eae3
#define CHAR_C      0x0000f88f
#define CHAR_T      0x0000f444
#define CHAR_L      0x00004446
#define CHAR_L_CAP  0x0000888f
#define CHAR_ABS    0x00004444

#define CHAR_0      0x0000f99f
#define CHAR_1      0x0000c44e
#define CHAR_2      0x0000f3cf
#define CHAR_3      0x0000f71f
#define CHAR_4      0x000099f1
#define CHAR_5      0x0000fc3f
#define CHAR_6      0x00008f9f
#define CHAR_7      0x0000f111
#define CHAR_8      0x0000f9ff
#define CHAR_9      0x0000f9f1

int main() {

	// __asm__("la t0, %0" : : "i"(&ISR));
	// // __asm__("csrrw x0, mtvec, t0");
	// // __asm__("li t0, 8");		// enable interrupts
	// // __asm__("csrrw x0, mstatus, t0");

	// asm("add s6, x0, x0");
	// asm("");	

	float start_x = START_X;	
	float inc_x = X_I;
	float start_y = START_Y;
	float inc_y = Y_I;

	char* current_input = "(x + 1) * (x-1)";

	int i = 1;

	// Point center = {.x = COLUMN_SIZE / 2, .y = ROW_SIZE / 2};

	// draw_dot(center, COL_WHITE);

	// int address =  (center.y << 7) | center.x;
	// *write_address_ptr = address;
	// *write_data_ptr = COL_WHITE;
	// draw_dot(center, COL_WHITE);

    // testing drawing stuffs
    int flag = 0;
    for(i = 0; i < COLUMN_SIZE; i++) {
        Point p1 = {.x = 1, .y = i};
        Point p2 = {.x = COLUMN_SIZE + 1, .y = i};
        if(flag) {
            draw_rect(p1, p2, COL_RED);
            flag = 0;
        }
        else {
            draw_rect(p1, p2, COL_WHITE);
            flag = 1;
        }
    }

    draw_background(COL_BLUE);

    // test drawing character
    Point char_point;
    char_point.x = 40;
    char_point.y = 25;
    draw_character(char_point, CHAR_0, 0xFF);

	while (1) // never break
	{
		// Do key input stuff...
		if(s6 == 1) {
			// char new_char = parse_scan_code();
			// if(new_char != -1 && new_char != '\n' && new_char != BACKSPACE) {
			// 	char str[] = {new_char};
			// 	strcat(current_input, str);
			// }
			// else if(new_char == BACKSPACE) {
			// 	current_input[strlen(current_input) - 1] = '\0';
			// }

			// // Disable interrupt flag. 
			// s6 = 0;
			// // Desire to try to plot once we break

			// if(parse_scan_code() == '\n') {
			// 	float current_x = start_x;
			// 	float prev_y = execute_real_function(start_x - inc_x, current_input);

			// 	float y_pixel = (-prev_y + start_y) / inc_y + ROW_SIZE;

			// 	for(int i = 0; i < COLUMN_SIZE; i++){		// i will be our col pixel. We graph from -x to pos x
			// 		float y = execute_real_function(current_x, current_input);
			// 		float y_pixel_prime = (y + start_y) / inc_y + ROW_SIZE;
			// 		Point bottom_left = {.x = i, .y = (int) y_pixel};
			// 		Point top_right = {.x = i, .y = (int) y_pixel_prime};
			// 		draw_rect(bottom_left, top_right, COL_RED);
			// 		start_x += inc_x;
			// 	}
			// }

		}


		// float current_x = start_x;
		// float prev_y = execute_real_function(start_x - inc_x, current_input);

		// float y_pixel = (-prev_y + start_y) / inc_y + ROW_SIZE;

		// for(int i = 1; i < COLUMN_SIZE - 1; i++){		// i will be our col pixel. We graph from -x to pos x
		// 	float y = execute_real_function(current_x, current_input);
		// 	float y_pixel_prime = (-y + start_y) / inc_y + ROW_SIZE;
		// 	Point bottom_left = {.x = i, .y = (int) y_pixel};
		// 	Point top_right = {.x = i, .y = (int) y_pixel_prime};
		// 	draw_rect(bottom_left, top_right, COL_RED);
		// 	start_x += inc_x;
		// }
	}

	return 0;
	
}

// END MAIN

// Plotting BEGIN

// Should fill a square with black between (x_1,y_1) and (x_2,y_2). It's required that x_1 <= x_2 and likewise for y or else nothing is drawn.
void draw_rect(Point p1, Point p2, int rgb) {

	// Swap if need be. 
	if(p1.x > p2.x){
		int temp = p1.x;
		p1.x = p2.x;
		p2.x = temp;
	}

	if(p1.y > p2.y){
		int temp = p1.y;
		p1.y = p2.y;
		p2.y = temp;
	}

	for(int i = p1.x; i <= p2.x; i++) {
		for(int j = p1.y; j <= p2.y; j++){
			Point temp;
			temp.x = i;
			temp.y = j;
			draw_dot(temp, rgb);
		}
	}
}

// Draw the color at position (x,y) with HSV color
volatile void draw_dot(Point p, int rgb) {

	// Store the data at the appropriate point
	int address =  (p.y << 7) | p.x;
	*write_address_ptr = address;
	*write_data_ptr = rgb;
}

void draw_background(int color) {
	const Point TOP_LEFT = {.x = 0, .y = 0};
	const Point BOTTOM_RIGHT = {.x = COLUMN_SIZE, .y = ROW_SIZE - 1};

	draw_rect(TOP_LEFT, BOTTOM_RIGHT, color);
}

// draw character, top right at point p
void draw_character(Point p, int c, int rgb) {
    // x and y offsets
    int _x = 0;
    int _y = 0;
    int mask = 0x8000;

    while (mask > 0) {
        // check if there is a pixel there
        int pixel = c & mask;
        if (pixel) {
            // draw
            Point temp;
            temp.x = p.x + _x;
            temp.y = p.y + _y;
            draw_dot(temp, rgb)
        }
        // shift mask to right
        mask = mask >> 1;
        // increment x or y
        if (_x == 3) {
            _x = 0;
            _y++;
        }
        else {
            _x++;
        }
    }
}

// Plotting END

// Functions BEGIN

// Using p.x, we evaulate f(x) = 1 2 + x - ...
// We start with the first two operands, then do the operation, rinse and repeat.
// If the function is too small, return 0.0f as a constant function.
//TODO: test this lol
float execute_real_function(float x, char function[]) {
	
	// 1. Clean the function input
	remove_spaces(function);

	char formated_func[strlen(function)];
	infixToPostfix(function, formated_func);

	// 2. Do the function via postfix
	if(strlen(formated_func) < 2 || !isdigit(formated_func[0]) || !isdigit(formated_func[1])) {
		return 0.0f;
	}

	float operand1 = function[0];
	float operand2 = function[1];

	int j = 2;

	while(j < strlen(formated_func)) {
		char operator = formated_func[j];
		if(!isOperator(operator)) {
			return -1.0f;
		}
		

		int num_inputs = getInc(operator);
		if(num_inputs == 1) {
			if(operand2 == 'x') {
				operand2 = doOperator(operator, x, 0); //DNC about operand2;
			}
			else {
				operand2 = doOperator(operator, operand2, 0); //DNC about operand2;
			}
			j++;
		}
		else { // inc was 2 for our assumptions
			if(operand1 == 'x' && operand2 == 'x'){
				operand1 = doOperator(operator, x, x);
			}
			else if(operand1 == 'x') {
				operand1 = doOperator(operator, x, operand2);
			}
			else if(operand2 == 'x') {
				operand1 = doOperator(operator, operand1, x);
			}
			else {
				operand1 = doOperator(operator, operand1, operand2);
			}
			j++;
			if(!isdigit(formated_func[j]) || formated_func[j] != 'x') {
				return -2.0f;
			}
			operand2 = formated_func[j];
			j++;
		}
	}

	return operand1;
}

// Take a function and remove the spaces:
// Ex: (1 + 2) - 3 -> (1+2)-3
void remove_spaces(char spaced_func[]) {
	int j = 0;
	for(int i = 0; spaced_func[i] != '\0'; i++) {
		if (spaced_func[i] != ' ') {
			spaced_func[j++] = spaced_func[i];
		}
	}
	spaced_func[j] = '\0';
} 

// Functions END

// ISR:

// Return the character that we typed in here. Figure out the logic here ...
void ISR() {
	// keyboard code in ISR goes here ...

	// __asm__("addi sp, sp, -4");						 // push to stack
	// __asm__("sw   t0, 0(sp)");
	// __asm__("li   t0, 0x11000000");     			 // load t0 with MMIO
	// __asm__("lw   %0, 0x100(t0)" : "=r"(scan_code)); // write to scan_code
	// __asm__("addi s6, x0, 1");   					 // set interrupt flag
	// __asm__("lw   t0,  0(sp)");   					 // pop from stack
	// __asm__("addi sp, sp, 4");
	// __asm__("mret");								 // ret.
}

// Stack stuff for post -> infix

void push(Stack *s, char c) {
    if (s->top < MAX_SIZE) {
        s->stack[++s->top] = c;
    }
}

char pop(Stack *s) {
    if (s->top >= 0) {
        return s->stack[s->top--];
    }
    return '\0';
}

int precedence(char op) {
    switch (op) {
        case '+':
        case '-':
            return 1;
        case '*':
        case '/':
            return 2;
        case '^':
		// functions
		case 's': // sin
		case 'c': // cos
		case 't': // tan
		case 'S': // arcsin
		case 'C': // arccos
		case 'T': // arctan
		case 'l': // ln(x)
		case 'L': // log(x)
		case '|': // abs(x)
            return 3;
    }
    return -1;
}

// get the postfix version of the current infix string. 
void infixToPostfix(char *infix, char *postfix) {
    Stack operatorStack;
    operatorStack.top = -1;

    int i, j = 0, len = strlen(infix);

    for (i = 0; i < len; i++) {
        char c = infix[i];

        if (c == '(') {
            push(&operatorStack, c);
        }
        else if (c == ')') {
            while (operatorStack.top >= 0 && operatorStack.stack[operatorStack.top] != '(') {
                postfix[j++] = pop(&operatorStack);
            }
            if (operatorStack.top >= 0 && operatorStack.stack[operatorStack.top] == '(') {
                pop(&operatorStack);
            }
        }
        else if (c >= '0' && c <= '9') {
            postfix[j++] = c;
        }
        else if (isOperator(c)) {
            while (operatorStack.top >= 0 && precedence(c) <= precedence(operatorStack.stack[operatorStack.top])) {
                postfix[j++] = pop(&operatorStack);
            }
            push(&operatorStack, c);
        }
    }

    while (operatorStack.top >= 0) {
        postfix[j++] = pop(&operatorStack);
    }

    postfix[j] = '\0';
}

int isOperator(char input) {
	switch(input) {
		case '+':
		case '-':
		case '*':
		case '/':
		case '^':
		case 's':
		case 'q':
		case 'c':
		case 't':
		case 'l':
		case 'L':
		case '|':
		return 1;
	}
	return 0;
}

// Do operand1 (operator) operand2. If only one input is needed just uses operand1. 
float doOperator(char operator, float operand1, float operand2) {
	switch(operator) {
		case '+':
			return operand1 + operand2;
		case '-':
			return operand1 - operand2;
		case '*':
			return operand1 * operand2;
		case '/':
			return operand1 / operand2;
		case '^':
			return powf(operand1, operand2);
		case 's':
			return sinf(operand1);
		case 'q':
			return sqrtf(operand1);
		case 'c':
			return cosf(operand1);
		case 't':
			return tanf(operand1);
		case 'l':
			return logf(operand1);
		case 'L':
			return log10f(operand1);
		case '|':
			return (operand1 < 0.0f) ? -1 * operand1 : operand1;
		return 1;
	}
	return 0;
}

// How many inputs does this function need to take?
int getInc(char operator) {
	switch (operator)
	{
		case '+':
		case '-':
		case '*':
		case '/':
		case '^':
			return 2;
		case 's': //sin
		case 'q': //sqrt
		case 'c': //cos
		case 't': //tan
		case 'l': //ln
		case 'L': //log
		case '|': //abs |x|
			return 1;
		default:
			return -1;
	}
}

char parse_scan_code() {
	if(!is_shift) {
		switch (scan_code)
		{
		case 0x55:
			return '+';
		case 0x3E:
			return '*';
		case 0x36:
			return '^';
		case 0x4B: // L
			return 'L';
		case 0x5D:
			return '|';
		default:
			// go to bottom switch
		}
	}

	switch (scan_code)
	{
		case 0x4E:
			return '-';
		case 0x4A:
			return '/';
		case 0x1B:
			return 's';
		case 0x15:
			return 'q';
		case 0x21:
			return 'c';
		case 0x2C:
			return 't';
		case 0x4B:
			return 'l';
		case 0x5A:
			return '\n';
		case 0x66:
			return BACKSPACE;
		default:
			return -1;

	}
}
