/*
 * Filename: graphviz.l
 * Purpose : Parser for a graph language from AT&T, known by the names Graphviz
 *           and dot.
 * Author  : Nikolaos Kavvadias (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013, 
 *                                  2014
 *           Original grammar for the GOLD parser builder written by
 *           Richard Schneider <richard@blackhen.co.nz>
 * Date    : 04-Oct-2014
 * Revision: 1.0.0 (14/10/04)
 *           Updated for github.
 *           
 */ 
%{
  #include <stdio.h>
  
  #define YYSTYPE unsigned int
  #define YYDEBUG 1
  #define MAXSIZE 1024

  extern char *yytext;
  extern FILE *debug_file;

  extern char any_name_s[MAXSIZE];
%}

%token T_LPAREN
%token T_RPAREN
%token T_COMMA
%token T_COLON
%token T_SEMI
%token T_AT
%token T_LBRACKET
%token T_RBRACKET
%token T_LBRACE
%token T_RBRACE
%token T_STRING
%token T_EQ
%token T_DIGRAPH
%token T_EDGE
%token T_DEDGE
%token T_UEDGE
%token T_GRAPH
%token T_ID
%token T_NODE
%token T_STRICT
%token T_SUBGRAPH

%start graph

%%

graph : strict graph_type T_ID T_LBRACE stmt_list T_RBRACE
    ;

strict : /* empty */ 
    | T_STRICT
    ;

graph_type : T_DIGRAPH
    | T_GRAPH
    ;

stmt_list	:	stmt_list1
    | /* empty */
		;

stmt_list1 :	stmt
    | stmt_list1 stmt
		;
stmt :	stmt1
		|	stmt1 T_SEMI
		;

stmt1 : attr_stmt
    | node_stmt
    | edge_stmt
    | subgraph
    | attr_assignment
    ;

attr_stmt : T_GRAPH attr_list
    | T_NODE attr_list
    | T_EDGE attr_list
    ;

attr_list : T_LBRACKET a_list T_RBRACKET
    | T_LBRACKET T_RBRACKET
    | T_LBRACKET a_list T_RBRACKET attr_list
    | T_LBRACKET T_RBRACKET attr_list
    ;

a_list : attr_assignment
    | attr_assignment T_COMMA a_list
    | attr_assignment a_list 
    ;

attr_assignment : T_ID T_EQ idrhs
    ;
								
idrhs : T_ID 
    | T_STRING
		;        

node_stmt : node_id 
    | node_id attr_list 
    ;

node_id : T_ID
    | T_ID port
    ;

port : port_location 
    | port_angle 
    | port_location port_angle 
    | port_angle port_location 
    ;

port_location : T_COLON T_ID
    | T_COLON T_ID T_LPAREN T_ID T_COMMA T_ID T_RPAREN
    ;

port_angle : T_AT T_ID
    ;

edge_stmt : node_id edgerhs 
    | node_id edgerhs attr_list 
    | subgraph edgerhs 
    | subgraph edgerhs attr_list 
    ;

edgerhs : edgeop node_id
    | edgeop node_id edgerhs
    ;

subgraph : T_SUBGRAPH T_ID T_LBRACE stmt_list T_RBRACE
    | T_SUBGRAPH T_LBRACE stmt_list T_RBRACE
    | T_LBRACE stmt_list T_RBRACE
    ;

edgeop   : T_UEDGE
    | T_DEDGE
    ;

%%

#include <stdio.h>
#include <string.h>    /* For strcmp, strlen */
#include <sys/types.h> /* Needed in print_out */
#include <sys/stat.h>  /* Needed in print_out */
#include <fcntl.h>
#include <errno.h>

extern int column;
extern FILE *yyin;

int yyerror(char *s)
{
  fflush(stdout);
  printf("\n%*s\n%*s\n", column, "^", column, s);
  
  return 0;
}
