%{
#include<cstdio>
#include<stdio.h>
//#include<iostrem>
#include<cstdlib>
#include<string>
#include<vector>
#include "SymbolTable.h"
using namespace std;




int lineCount = 1;
int errorCount = 0;
int warningCount = 0;
int bucketLength = 10;
//string currentTypeSpecifier;
SymbolTable *st = new SymbolTable(bucketLength);
FILE *inputFile;
FILE *errorFile;
FILE *logFile;


vector<string>typeSpecifier;
vector<string>value;
vector<string> declarationID;
vector<int> declarationSize;
vector<string> argumentList;


extern FILE *yyin;

int yylex();
void yyerror(const char *s)
{
    printf("error occured at %d: %s\n\n",lineCount,s);
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE
%token VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token ID CONST_CHAR CONST_FLOAT CONST_INT STRING


%nonassoc NO_ELSE
%nonassoc ELSE


%right ASSIGNOP
%left LOGICOP
%left BITOP
%left RELOP 
%left ADDOP 
%left MULOP
%right INCOP DECOP NOT



%error-verbose



%union {
    SymbolInfo* symbol;
}


%type <s>start
%%




start : 
program {

}

program : 
program unit {
    string type = "program" ;
    string symbol = $<symbol>1->getSymbol()+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  program : program unit\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    

}
| unit {
    string type = "program" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  program : unit\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

unit :
var_declaration {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : var_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| func_declaration {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : func_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| func_definition {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : func_definition\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
					
func_declaration :
type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
    string type = "func_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    


    SymbolInfo* found = st->lookUpCurrent($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = false;
        found->e->returnType = $<symbol>1->getSymbol();
        bool voidFound = false;
        for(int i=0;i<typeSpecifier.size();i++)
        {
            if(typeSpecifier[i].compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d :for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                fprintf(errorFile,"ERROR at line no %d : for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                voidFound = true;
                break;
            }
            found->typeSpecifier.push_back(typeSpecifier[i]);
            found->value.push_back(value[i]);
        }
        if(!voidFound)
        {
            st->insertion(found);
        
        }
        //printf("typeSpecifier size %d \n",typeSpecifier.size());
        typeSpecifier.clear();
        value.clear();
        
        //printf("typeSpecifier size %d \n",typeSpecifier.size());
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
        
        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
           //printf("%d %d\n\n",found->typeSpecifier.size(),typeSpecifier.size());
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            //printf("check\n");
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            
        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    
                    break;
                }
            }

            
        }

        //printf("typeSpecifier size %d \n",typeSpecifier.size());
        typeSpecifier.clear();
        value.clear();

                
    }
    
    
    
}
| type_specifier ID LPAREN RPAREN SEMICOLON {
    string type = "func_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo* found = st->lookUpCurrent($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = false;
        found->e->returnType = $<symbol>1->getSymbol();
        st->insertion(found);
        
        
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
            
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                  
                    break;
                }
            }
        }

                
    }
}

func_definition : 
type_specifier ID LPAREN parameter_list RPAREN compound_statement{
    //printf("kill me\n");
    //printf("%s %s\n",$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
        
    string type = "func_definition" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    /*for(int i=0;i<typeSpecifier.size();i++)
    {
        fprintf(logFile,"%s\n\n",typeSpecifier[i].c_str());
        fprintf(logFile,"%s\n\n",value[i].c_str());
        
    }*/
    SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    
    //printf("%d\n",found);
    //st->printFile(errorFile);
    
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = true;
        found->e->returnType = $<symbol>1->getSymbol();

        //printf("in function definition cfg typeSpecifier size %d \n",typeSpecifier.size());
        bool voidFound = false;
        for(int i=0;i<typeSpecifier.size();i++)
        {
            if(typeSpecifier[i].compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d :for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                fprintf(errorFile,"ERROR at line no %d : for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                voidFound = true;
                break;
            }
            found->typeSpecifier.push_back(typeSpecifier[i]);
            found->value.push_back(value[i]);
        }
        //printf("in function definition cfg %d %d\n",found->typeSpecifier.size(),typeSpecifier.size());
        if(!voidFound)
        {
            st->insertion(found);
        
        }
        //typeSpecifier.clear();
        //value.clear();
        
    }
    else 
    {
        //printf("killme\n");
        //printf("%s %s %s\n",found->e->returnType.c_str(),$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
            
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
    
        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_defined == true) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            //printf("%s %s\n",found->e->returnType.c_str(),$<symbol>1->getSymbol().c_str());
            
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    
                    break;
                }
            }
            found->e->is_defined = true;

            
        }
        
        

                
    }
    typeSpecifier.clear();
    value.clear();
    
    
        
}
    


| type_specifier ID LPAREN RPAREN compound_statement {
    string type = "func_definition" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = true;
        found->e->returnType = $<symbol>1->getSymbol();
        st->insertion(found);
        
        
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_defined == true) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    
                    break;
                }
            }
        }

                
    }
    typeSpecifier.clear();
    value.clear();
    
}

parameter_list : 
parameter_list COMMA type_specifier ID {
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    typeSpecifier.push_back($<symbol>3->getSymbol());
    value.push_back($<symbol>4->getSymbol());
    //printf("%s %s\n",$<symbol>3->getSymbol().c_str(),$<symbol>4->getSymbol().c_str());
    //printf("typeSpecifier size %d \n",typeSpecifier.size());
    fprintf(logFile,"At line no : %d  parameter_list : parameter_list COMMA type_specifier ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| parameter_list COMMA type_specifier {
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    typeSpecifier.push_back($<symbol>3->getSymbol());
    value.push_back("");
    //printf("%s %s\n",$<symbol>3->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
    
    fprintf(logFile,"At line no : %d  parameter_list : parameter_list COMMA type_specifier\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| type_specifier ID{
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    typeSpecifier.push_back($<symbol>1->getSymbol());
    value.push_back($<symbol>2->getSymbol());
    //printf("%s %s\n",$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
    
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  parameter_list : type_specifier ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| type_specifier {
    
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol();
    typeSpecifier.push_back($<symbol>1->getSymbol());
    value.push_back("");
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  parameter_list : type_specifier\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    //printf("%s \n",$<symbol>1->getSymbol().c_str());
    

}

compound_statement : LCURL
{
    //printf("hello world");
    //printf("hello world from LCURL\n\n");
    st->enterScope();
    //printf("new scope opened\n");
    for(int i=0;i<typeSpecifier.size();i++)
    {
        string symbol = value[i];
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("error for %s\n",symbol.c_str());
            //printf("error found %d\n",lineCount);
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            
            continue;
        }
        //int size1 = declarationSize[i];
        string type = typeSpecifier[i];
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("%s\n",send->e->returnType.c_str());
        st->insertion(send);
        

    }
    //typeSpecifier.clear();
    //value.clear();

} statements RCURL
{
    
    //printf("entering into new scope\n\n");
    string type = "compound_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n"+$<symbol>3->getSymbol()+"\n"+$<symbol>4->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  compound_statement : LCURL statements RCURL\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    
    //printf("%s\n\n",$<symbol>3->getSymbol().c_str());
    /*for(int i=0;i<declarationID.size();i++)
    {
        //printf("identifier %s size %d\n\n",declarationID[i].c_str(),declarationSize[i]);
    }*/

    

    st->printFile(logFile);
    st->exitScope();
    //printf("scope exited\n");
}

| LCURL 
{
    st->enterScope();
    //printf("new scope opened\n");
    for(int i=0;i<typeSpecifier.size();i++)
    {
        string symbol = value[i];
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("error for %s\n",symbol.c_str());
            //printf("error found %d\n",lineCount);    
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            
            continue;
        }
        //int size1 = declarationSize[i];
        string type = typeSpecifier[i];
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("%s\n",send->e->returnType.c_str());
        st->insertion(send);
        

    }
    //typeSpecifier.clear();
    //value.clear();
} RCURL 
{
    string type = "compound_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n\n"+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  compound_statement : LCURL RCURL\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

var_declaration :
type_specifier declaration_list SEMICOLON {

    string type = "var_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  var_declaration : type_specifier declaration_list SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    //printf("%d",declarationID.size());
    if($<symbol>1->getSymbol().compare("void")==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : can not declare varaible of void type\n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : can not declare varaible of void type\n\n",lineCount,symbol.c_str());
            
    }
    for(int i=0;i<declarationID.size();i++)
    {
        string symbol = declarationID[i];
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("kill me 2 %s\n",symbol.c_str());    
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount,symbol.c_str());
            
            continue;
        }
        int size1 = declarationSize[i];
        string type = $<symbol>1->getSymbol();
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("kill me %s\n",symbol.c_str());
        //printf("%s\n",send->e->returnType.c_str());
        if(size1!=0)
        {
            //printf("kill me %s\n",symbol.c_str());
            send->e->is_array = true;
            //printf("%d %d\n",send->e->is_array,size1);
            send->e->arrayLength = size1;
        }
        st->insertion(send);
        

    }
    declarationID.clear();
    declarationSize.clear();
    

}

type_specifier :
INT {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : INT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| FLOAT {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : FLOAT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| VOID {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : VOID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

declaration_list :
declaration_list COMMA ID {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : declaration_list COMMA ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    string id = $<symbol>3->getSymbol();
    declarationID.push_back(id);
    int size1 = 0;
    //printf("printing size1 of %d\n",size1);
    declarationSize.push_back(size1);
    //printf("printing size again %d\n",declarationSize[declarationSize.size()-1]);

    /*for(int i=0;i<declarationSize.size();i++)
    {
        //printf("kill me %d\n",declarationSize[i]);
        //printf("kill me again %s\n",declarationID[i].c_str());
    }*/

    

}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    string id = $<symbol>3->getSymbol();
    //printf("kill me 3 %s\n",id.c_str());
    declarationID.push_back(id);
    int size1 = atoi($<symbol>5->getSymbol().c_str());
    //printf("%d\n",size1);
    declarationSize.push_back(size1);


}
| ID {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    string id = $<symbol>1->getSymbol();
    declarationID.push_back(id);
    int size1 = 0;
    //printf("printing size1 of %d\n",size1);
    declarationSize.push_back(size1);
    //printf("printing size again %d\n",declarationSize[declarationSize.size()-1]);
    /*for(int i=0;i<declarationSize.size();i++)
    {
        //printf("kill me %d\n",declarationSize[i]);
        //printf("kill me again %s\n",declarationID[i].c_str());
    }*/

}
| ID LTHIRD CONST_INT RTHIRD {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    string id = $<symbol>1->getSymbol();
    //printf("kill me 3 %s\n",id.c_str());
    declarationID.push_back(id);
    int size1 = atoi($<symbol>3->getSymbol().c_str());
    declarationSize.push_back(size1);



}

statements :
statement {
    string type = "statements" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statements : statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| statements statement {
    string type = "statements" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statements : statements statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


}

statement :
var_declaration {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : var_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    



}
| expression_statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : expression_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| compound_statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+" "+$<symbol>7->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| IF LPAREN expression RPAREN statement %prec NO_ELSE{
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : IF LPAREN expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| IF LPAREN expression RPAREN statement ELSE statement{
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+" "+$<symbol>7->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    
}
| WHILE LPAREN expression RPAREN statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : WHILE LPAREN expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| PRINTLN LPAREN ID RPAREN SEMICOLON {
    //println handled in lexxer 
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| RETURN expression SEMICOLON {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : RETURN expression SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


}  

expression_statement :
SEMICOLON {
    string type = "expression_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression_statement : SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| expression SEMICOLON {
    string type = "expression_statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression_statement : expression SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}

variable : 
ID {
    string type = "variable" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    SymbolInfo* v = $<symbol>$;
    v->e = new Extra;
    fprintf(logFile,"At line no : %d  variable : ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* found = st->lookUp(symbol);
    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    }
    else
    {
        if(found->e->is_array==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable name %s is an array so should be indexed properly\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : variable name %s is an array so should be indexed properly\n\n",lineCount,symbol.c_str());
        
        }
        else if(found->e->is_function==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
        

        }
        v->e->returnType = found->e->returnType;
    }

}
| ID LTHIRD expression RTHIRD {
    string type = "variable" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    SymbolInfo* v = $<symbol>$;
    v->e = new Extra;
    fprintf(logFile,"At line no : %d  variable : ID LTHIRD expression RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* exp = $<symbol>3;
    //printf("asdf %s\n",exp->e->returnType.c_str());
    if(exp->e->returnType.compare("float")==0||exp->e->returnType.compare("void")==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : for id %s index number should be integer \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : for id %s index number should be integer \n\n",lineCount,symbol.c_str());
       
    }

    string symbol1 = $<symbol>1->getSymbol();
    SymbolInfo* found = st->lookUp(symbol1);
    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    }
    else
    {
        
        if(found->e->is_array==false)
        {
            //printf("%d\n",v->e->is_array);
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable name %s is not an array \n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : variable name %s is not an array \n\n",lineCount,symbol.c_str());
         
        }
        else if(found->e->is_function==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
        

        }
        v->e->returnType = found->e->returnType;
        //printf("3. %s\n",found->e->returnType.c_str());
        //fprintf(logFile,"kill me\n\n");
        
        //st->printFile(logFile);
    }


}

expression :
logic_expression {
    string type = "expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression : logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg expression logic_expression\n");
        v->e->returnType = "int"; // had no option
    }



}
| variable ASSIGNOP logic_expression {
    string type = "expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression : variable ASSIGNOP logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo *var = $<symbol>1;
    SymbolInfo *le = $<symbol>3;
    
    string retv = var->e->returnType;
    string retle = le->e->returnType;
    
    //printf("1. %s %s\n",var->getSymbol().c_str(),retv.c_str());

    //printf("2. %s %s\n",le->getSymbol().c_str(),retle.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    
    if(retv.compare(retle)==0)
    {
        v->e->returnType = retv;

    }
    else
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : type mismatch in assignment operator\n\n",lineCount,$<symbol>3->getSymbol().c_str());
        fprintf(errorFile,"ERROR at line no %d : type mismatch in assignment operator\n\n",lineCount,$<symbol>3->getSymbol().c_str());
           
        if(retle.compare("float")==0 && retv.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,$<symbol>3->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,$<symbol>3->getSymbol().c_str());
            
            v->e->returnType = retv;
        }
        else if(retle.compare("int")==0 && retv.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
            v->e->returnType = retv;
        }
        else
        {
            if(retle.compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d : function %s is a void function\n\n",lineCount,$<symbol>3->getSymbol().c_str());
                fprintf(errorFile,"ERROR at line no %d : function %s is a void function\n\n",lineCount,$<symbol>3->getSymbol().c_str());
           
            }

            if(retv.compare("float")||retv.compare("int"))
            {
                v->e->returnType = retv;
        
            }
            else
            {
                printf("Had no option at cfg expression : variable ASSIGNOP logic_expression\n");
                v->e->returnType = "int";
            }
                
        }

    }

}

logic_expression :
rel_expression {
    string type = "logic_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  logic_expression : rel_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg logic_expression rel_expression term\n");
        v->e->returnType = "int"; // had no option
    }

}
| rel_expression LOGICOP rel_expression {
    string type = "logic_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  logic_expression : rel_expression LOGICOP rel_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    v->e->returnType = "int";
    
}

rel_expression :
simple_expression {
    string type = "rel_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  rel_expression : simple_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg rel_expression simple_expression \n");
        v->e->returnType = "int"; // had no option
    }
}
| simple_expression RELOP simple_expression {
    string type = "rel_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  rel_expression : simple_expression RELOP simple_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    //SymbolInfo* se1 = $<symbol>1;
    //SymbolInfo* se2 = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    v->e->returnType = "int";
    /*if(se1->e->returnType.compare("float")==0  || se2->e->returnType.compare("float")==0)
    {
        v->e->returnType = "int";
        if(se1->e->returnType.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se1->getSymbol().c_str());
        
        }
        if(se2->e->returnType.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se2->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se2->getSymbol().c_str());
        

        }
    }
    else if(se1->e->returnType.compare("int")==0  && se2->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg simple_expression RELOP simple_expression term\n");
        v->e->returnType = "int";
    }*/



}

simple_expression :
term {
    string type = "simple_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  simple_expression : term\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg simple_expression term\n");
        v->e->returnType = "int"; // had no option
    }


}
| simple_expression ADDOP term {
    string type = "simple_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  simple_expression : simple_expression ADDOP term\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());





    SymbolInfo* se = $<symbol>1;
    SymbolInfo* t1 = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if(t1->e->returnType.compare("float")==0  || se->e->returnType.compare("float")==0)
    {
        v->e->returnType = "float";
        if(t1->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
        
        }
        else if(se->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,se->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,se->getSymbol().c_str());
        

        }
    }
    else if(t1->e->returnType.compare("int")==0  && se->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg simple_expression addop term\n");
        v->e->returnType = "int";
    }

}

term :
unary_expression {
    string type = "term" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  term : unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg term unary_expression\n");
        v->e->returnType = "int"; // had no option
    }

}
| term MULOP unary_expression {
    string type = "term" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  term : term MULOP unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* t1 = $<symbol>1;
    SymbolInfo* ue = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if(t1->e->returnType.compare("float")==0  || ue->e->returnType.compare("float")==0)
    {
        if($<symbol>2->getSymbol().compare("%")==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : for expression %s both operand of modulus operator should be integer \n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : for expression %s both operand of modulus operator should be integer \n\n",lineCount,symbol.c_str());
        
        }
        v->e->returnType = "float";
        if(t1->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
        
        }
        else if(ue->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,ue->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,ue->getSymbol().c_str());
        

        }
    }
    else if(t1->e->returnType.compare("int")==0  && ue->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg term mulop unary_expression\n");
        v->e->returnType = "int";
    }
}

unary_expression : 
ADDOP unary_expression {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : ADDOP unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg addop unary_expression\n");
        
        v->e->returnType = "int"; // had no option
    }

}
| NOT unary_expression {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : NOT unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg not unary_expression\n");
        
        v->e->returnType = "int"; // had no option

    }

}
| factor {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : factor\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg unary_expression factor %s\n",symbol.c_str());

        
        v->e->returnType = "int"; // had no option
    }

}

factor :
variable {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;
    fprintf(logFile,"At line no : %d  factor : variable\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| ID LPAREN argument_list RPAREN {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    
    fprintf(logFile,"At line no : %d  factor : ID LPAREN argument_list RPAREN\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    string symbol1 = $<symbol>1->getSymbol();
    SymbolInfo* found = st->lookUp(symbol1);

    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : function name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : function name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    
    }
    else
    {
        if(found->e->is_function==false)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : ID %s is not a function it is a variable \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : ID %s is not a function it is a variable \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
        }
        vector<string> varType = found->typeSpecifier;
        //printf("%d \n",found->typeSpecifier.size());
        int s1 = varType.size();
        int s2 = argumentList.size();
        int s;
        //printf("%d %d %s\n",s1,s2,found->getSymbol().c_str());
        if(s1!=s2)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : for function %s argument size doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : for function %s argument size doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
            //printf("%s %d %d\n",$<symbol>1->getSymbol().c_str(),s1,s2);

        }
        else
        {
            for(int i=0;i<varType.size();i++)
            {
                if(varType[i].compare(argumentList[i])!=0)
                {
                    if(argumentList[i].compare("float")==0)
                    {
                        warningCount++;
                        fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i+1);
                        fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i+1);
            
                    }
                    else if(argumentList[i].compare("int")==0)
                    {
                        warningCount++;
                        fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i);
                        fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i);
            
                    }
                    else
                    {
                        errorCount++;
                        fprintf(logFile,"ERROR at line no %d : for function %s argument serial doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
                        fprintf(errorFile,"ERROR at line no %d : for function %s argument serial doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
        
                    }
                    
                }
            }

        }
        argumentList.clear();
        string ret = found->e->returnType;
        //printf("%s\n",ret.c_str());
        v->e->returnType = ret;

        //code portion below not needed anymore
        /*if(ret.compare("int")==0 || ret.compare("float")==0)
        {
            
        }
        else
        {
            //printf("had no option at cfg factor id LPAREN argument_list\n");
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name %s is a void function \n\n",lineCount,found->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : function name %s is a void function \n\n",lineCount,found->getSymbol().c_str());
        
            v->e->returnType = "int";
        }*/

        // we have to write more code to check the appropiate arguments
    }
}
| LPAREN expression RPAREN {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : LPAREN expression RPAREN\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg LPAREN expression RPAREN %s\n",symbol.c_str());
        v->e->returnType = "int"; // had no option
    }

   

}
| CONST_INT {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    SymbolInfo* v = $<symbol>$;
    v->e->returnType = "int";
    fprintf(logFile,"At line no : %d  factor : CONST_INT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| CONST_FLOAT {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    SymbolInfo* v = $<symbol>$;
    v->e->returnType = "float";
    fprintf(logFile,"At line no : %d  factor : CONST_FLOAT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| variable INCOP {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : variable INCOP\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    //$<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;

}
| variable DECOP {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : variable DECOP\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    //$<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;

}

argument_list : 
arguments {
    string type = "argument_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  argument_list : arguments\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| {

    string type = "argument_list" ;
    string symbol = "";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  argument_list : \n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

arguments :
arguments COMMA logic_expression {
    string type = "arguments" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  arguments : arguments COMMA logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    argumentList.push_back($<symbol>3->e->returnType.c_str());
}
| logic_expression {
    string type = "argument_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  arguments : logic_expression \n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    argumentList.push_back($<symbol>1->e->returnType.c_str());

}




%%

/*
int lineCount = 1;
int errorCount = 0;
SymbolTable *st;
FILE *inputFile;
FILE *errorFile;
FILE *logFile;

extern FILE *yyin;

int yylex();
int yyparse();
*/

int main(int argc, char *argv[])
{
    inputFile = fopen(argv[1],"r");
    if(!inputFile)
    {
        printf("Couldn't open input file\n");
        return 0;
    }
    
    //st = new SymbolTable(bucketLength);
    errorFile = fopen("1605062_error.txt","w");
    logFile = fopen("1605062_log.txt","w");
    
    yyin = inputFile;
    yyparse();
    
    //symbol table should be printed here in logfile
    fprintf(logFile,"total lines in the code are %d\n\n",lineCount);
    fprintf(logFile,"total warnings in the code are %d\n\n",warningCount);
    fprintf(logFile,"total errors in the code are %d\n\n",errorCount);
    fprintf(logFile,"\n\n");
    fprintf(errorFile,"total lines in the code are %d\n\n",lineCount);
    fprintf(errorFile,"total warnings in the code are %d\n\n",warningCount);
    fprintf(errorFile,"total errors in the code are %d\n\n",errorCount);
    fprintf(errorFile,"\n\n");
    

    st->printFile(logFile);
    fclose(inputFile);
    fclose(errorFile);
    fclose(logFile);
    
    
}




/*variable    : ID  { 
    fprintf(logFile,"id name %s\n",$<symbol>1->getSymbol()+" "+.c_str());

}*/