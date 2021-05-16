#include<cstdio>
#include<stdio.h>
//#include<iostrem>
#include<cstdlib>
#include<string>
#include<vector>
//#include"y.tab.h"
using namespace std;




//extern FILE *logFile;

class Extra
{
    public:
    bool is_function = false;
    bool is_defined = false;
    bool is_array = false;
    int arrayLength = 0;
    string returnType;
};


class SymbolInfo
{
    string name;
    string type;
    SymbolInfo* next;

public:
    vector<string>typeSpecifier;
    vector<string>value;
   //bool isFunction;
    Extra* e;

    SymbolInfo* getNext()
{
    return this->next;
}
    string getSymbol()
{
    return name;
}

string getType()
{
    return type;
}
    void setType(string type)
{
    this->type = type;
}
    void setSymbol(string symbol)
{
    name = symbol;
}
    //void setType(string type);
    void setNext(SymbolInfo* n)
{
    next = n;
}
    SymbolInfo()
{
    next =0;
}
    SymbolInfo(string name,string type)
{
    this->name = name;
    this->type = type;
    next = 0;
}
    ~SymbolInfo()
    {
    //cout<<"symbol info destructor called"<<endl;
    }
};




/* SymbolInfo::~SymbolInfo()
{
    //cout<<"symbol info destructor called"<<endl;
}
SymbolInfo::SymbolInfo()
{
    next =0;
}
SymbolInfo::SymbolInfo(string name,string type)
{
    this->name = name;
    this->type = type;
    next = 0;
}

void SymbolInfo::setSymbol(string symbol)
{
    name = symbol;
}

void SymbolInfo::setType(string type)
{
    this->type = type;
}

void SymbolInfo::setNext(SymbolInfo* n)
{
    next = n;
}

string SymbolInfo::getSymbol()
{
    return name;
}

string SymbolInfo::getType()
{
    return type;
}

SymbolInfo* SymbolInfo::getNext()
{
    return this->next;
}
*/
class ScopeTable
{
    SymbolInfo **arr;
    ScopeTable *parent;
    int bucketLength;
    int hashFunc(string symbol)
{
    int strlen = symbol.size();
    int ind = 0;
    for(int i=0; i<5; i++)
    {
        if(strlen<=i)
        {
            break;
        }
        ind += symbol[i];
    }
    return ind%bucketLength;
}
public:
    void printFile(FILE *ptr)
{
    fprintf(ptr,"printing current scopetable before exiting\n\n");
    for(int i=0; i<bucketLength; i++)
    {
        //FILE *ptr = logFile;
        bool notEmpty = false;
        //fprintf(ptr,"I was here");
        SymbolInfo* temp = arr[i];
        
        if(temp!=0)
        {
            //cout<<i<<"--->  ";
            fprintf(ptr,"%d--> ",i);
            notEmpty = true;
        }
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            fprintf(ptr,"<%s : %s> ",temp->getSymbol().c_str(),temp->getType().c_str());
            temp=temp->getNext();
        }
        if(notEmpty)
        {
            notEmpty = false;
            fprintf(ptr,"\n\n");
        }
        //cout<<endl<<endl;
    }
}

~ScopeTable()
{
    for(int i=0; i<bucketLength; i++)
    {
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {

            this->deletion(temp->getSymbol());
            temp = arr[i];
        }
    }
    delete []arr;
    //cout<<"scopeTable deleted"<<endl;
}


ScopeTable(int bucketLength)
{
    parent = 0;
    this->bucketLength = bucketLength;
    arr = new SymbolInfo* [bucketLength];
    for(int i=0; i<bucketLength; i++)
    {
        arr[i]=0;
    }

}

void setParent(ScopeTable* p)
{
    parent = p;
}

ScopeTable* getParent()
{
    return parent;
}
SymbolInfo* lookUp(string symbol)
{
    int ind = hashFunc(symbol);
    //printf("%s\n",symbol.c_str());
    //printf("%d\n",ind);
    SymbolInfo *temp = arr[ind];
    //int k = temp;
    //printf("%p\n",temp);
    //int position = 0;
    while(temp!=0)
    {
        
        if(temp->getSymbol().compare(symbol)==0)
        {
            //printf("%s %s\n",temp->getSymbol().c_str(),symbol.c_str());
            return temp;

        }
        temp=temp->getNext();
    }
    return 0;
}

bool insertion(SymbolInfo *entry)
{
    string symbol = entry->getSymbol();
    SymbolInfo *found = lookUp(symbol);
    //printf("kill me %p\n",found);
    
    if(found==0)
    {
        int ind = hashFunc(symbol);
        found = arr[ind];
        if(found==0)
        {
            arr[ind]=entry;
        }
        else
        {
            while(found->getNext()!=0)
            {
                found=found->getNext();
            }
            found->setNext(entry);

        }
        return true;
    }
    //printf("kill me again%p\n",found);
    return false;
}



bool deletion(string symbol)
{
    SymbolInfo* found = lookUp(symbol);
    if(found==0)
    {
        return false;
    }
    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    if(temp==found)
    {
        arr[ind]=temp->getNext();
        delete temp;
    }
    else
    {
        SymbolInfo* parent =0;
        while(temp!=0)
        {

            if(temp==found)
            {
                parent->setNext(temp->getNext());
                delete temp;
                break;
            }
            parent=temp;
            temp=temp->getNext();
        }

    }
    return true;
}

void print()
{
    for(int i=0; i<bucketLength; i++)
    {
        //cout<<i<<"--->  ";
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            temp=temp->getNext();
        }
        //cout<<endl<<endl;
    }
}
void printPosition(string symbol)
{
    SymbolInfo *found=lookUp(symbol);
    if(found==0)
    {
        //cout<<"not found"<<endl;
        return;
    }


    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    int position = 0;
    while(temp)
    {
        if(temp->getSymbol().compare(symbol)==0)
        {
            //cout<<"at position "<<ind<<", "<<position<<endl<<endl;
            return;

        }
        temp=temp->getNext();
        position++;
    }
    return;
}


};

/* void ScopeTable::printFile()
{
    for(int i=0; i<bucketLength; i++)
    {
        FILE *ptr = logFile;
        bool notEmpty = false;
        SymbolInfo* temp = arr[i];
        if(temp!=0)
        {
            //cout<<i<<"--->  ";
            //fprintf(ptr,"%d--> ",i);
            notEmpty = true;
        }
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            //fprintf(ptr,"<%s : %s> ",temp->getSymbol().c_str(),temp->getType().c_str());
            temp=temp->getNext();
        }
        if(notEmpty)
        {
            notEmpty = false;
            //fprintf(ptr,"\n");
        }
        //cout<<endl<<endl;
    }
}

ScopeTable::~ScopeTable()
{
    for(int i=0; i<bucketLength; i++)
    {
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {

            this->deletion(temp->getSymbol());
            temp = arr[i];
        }
    }
    delete []arr;
    //cout<<"scopeTable deleted"<<endl;
}


ScopeTable::ScopeTable(int bucketLength)
{
    parent = 0;
    this->bucketLength = bucketLength;
    arr = new SymbolInfo* [bucketLength];
    for(int i=0; i<bucketLength; i++)
    {
        arr[i]=0;
    }

}

void ScopeTable::setParent(ScopeTable* p)
{
    parent = p;
}

ScopeTable* ScopeTable::getParent()
{
    return parent;
}
SymbolInfo* ScopeTable::lookUp(string symbol)
{
    int ind = hashFunc(symbol);
    //printf("%s\n",symbol.c_str());
    //printf("%d\n",ind);
    SymbolInfo *temp = arr[ind];
    //int k = temp;
    //printf("%p\n",temp);
    //int position = 0;
    while(temp!=0)
    {
        
        if(temp->getSymbol().compare(symbol)==0)
        {
            //printf("%s %s\n",temp->getSymbol().c_str(),symbol.c_str());
            return temp;

        }
        temp=temp->getNext();
    }
    return 0;
}

bool ScopeTable::insertion(SymbolInfo *entry)
{
    string symbol = entry->getSymbol();
    SymbolInfo *found = lookUp(symbol);
    //printf("kill me %p\n",found);
    
    if(found==0)
    {
        int ind = hashFunc(symbol);
        found = arr[ind];
        if(found==0)
        {
            arr[ind]=entry;
        }
        else
        {
            while(found->getNext()!=0)
            {
                found=found->getNext();
            }
            found->setNext(entry);

        }
        return true;
    }
    //printf("kill me again%p\n",found);
    return false;
}



bool ScopeTable::deletion(string symbol)
{
    SymbolInfo* found = lookUp(symbol);
    if(found==0)
    {
        return false;
    }
    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    if(temp==found)
    {
        arr[ind]=temp->getNext();
        delete temp;
    }
    else
    {
        SymbolInfo* parent =0;
        while(temp!=0)
        {

            if(temp==found)
            {
                parent->setNext(temp->getNext());
                delete temp;
                break;
            }
            parent=temp;
            temp=temp->getNext();
        }

    }
    return true;
}

void ScopeTable::print()
{
    for(int i=0; i<bucketLength; i++)
    {
        //cout<<i<<"--->  ";
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            temp=temp->getNext();
        }
        //cout<<endl<<endl;
    }
}
void ScopeTable::printPosition(string symbol)
{
    SymbolInfo *found=lookUp(symbol);
    if(found==0)
    {
        //cout<<"not found"<<endl;
        return;
    }


    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    int position = 0;
    while(temp)
    {
        if(temp->getSymbol().compare(symbol)==0)
        {
            //cout<<"at position "<<ind<<", "<<position<<endl<<endl;
            return;

        }
        temp=temp->getNext();
        position++;
    }
    return;
}

int ScopeTable::hashFunc(string symbol)
{
    int strlen = symbol.size();
    int ind = 0;
    for(int i=0; i<5; i++)
    {
        if(strlen<=i)
        {
            break;
        }
        ind += symbol[i];
    }
    return ind%bucketLength;
}
*/
class SymbolTable
{
    ScopeTable *current;
    int tableNo;
    int bucketLength;
public:
    //void getPosition(string symbol);
    void printFile(FILE *ptr)
{
    //printf("Im here");
    current->printFile(ptr);

}

~SymbolTable()
{
    //cout<<"In symboltable destructor"<<endl;
    ScopeTable* parent ;
    while(current!=0)
    {
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        parent=current->getParent();
        tableNo--;
        current->~ScopeTable();
        current=parent;

    }


}

SymbolTable(int bucketLength)
{
    this->bucketLength = bucketLength;
    current = new ScopeTable(bucketLength);
    tableNo =1;
    current->setParent(0);
}

bool enterScope()
{

    ScopeTable *child = new ScopeTable(bucketLength);
    child->setParent(current);
    current = child;
    tableNo++;
    //cout<<"New ScopeTable with id "<<tableNo<<" created"<<endl<<endl;
    return true;
}

bool exitScope()
{
    if(current!=0)
    {
        ScopeTable* parent = current->getParent();
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        current->~ScopeTable();
        //cout<<"ScopeTable with id "<<tableNo<<" remove"<<endl<<endl;
        current=parent;
        tableNo--;
        return true;
    }
    else
        return false;

}

bool insertion(SymbolInfo* entry)
{
    int result = current->insertion(entry);
    if(result==true)
    {
        //cout<<"Inserted in ScopeTable# "<<tableNo<<" ";
        current->printPosition(entry->getSymbol());
    }
    else
    {
        //cout<<"already exists"<<endl<<endl;
    }
    return result;

}

bool removal(string symbol)
{
    bool result = current->lookUp(symbol);
    if(result==true)
    {
        //cout<<"deleted entry from current ScopeTable ";
        current->printPosition(symbol);
        current->deletion(symbol);
    }
    else
    {
        //cout<<"not found"<<endl<<endl;

    }
    return result;



}

SymbolInfo* lookUpCurrent(string symbol)
{
   return current->lookUp(symbol); 
}

SymbolInfo* lookUp(string symbol)
{
    ScopeTable * temp = current;
    SymbolInfo * found =0;
    int tablenumber = tableNo;
    while(temp!=0)
    {
        found =temp->lookUp(symbol);
        if(found!=0)
        {
            //cout<<"found in ScopeTable# "<<tablenumber<<" ";
            temp->printPosition(symbol);
            break;
        }
        temp = temp->getParent();
        tablenumber--;
    }
    if(found==0)
    {
        //cout<<"not found"<<endl<<endl;
    }
    return found;
}

void printCurrent()
{
    //cout<<"ScopeTable# "<<tableNo<<endl<<endl;
    current->print();
}



void printAll()
{
    int tablenumber = tableNo;
    ScopeTable* temp = current;
    while(temp!=0)
    {
        //cout<<"ScopeTable# "<<tablenumber<<endl<<endl;
        temp->print();
        temp = temp->getParent();
    }
}

void printFileSymbolTable(FILE *ptr)
{
    
}

};
/* 
void SymbolTable::printFile()
{
    current->printFile();

}

SymbolTable::~SymbolTable()
{
    //cout<<"In symboltable destructor"<<endl;
    ScopeTable* parent ;
    while(current!=0)
    {
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        parent=current->getParent();
        tableNo--;
        current->~ScopeTable();
        current=parent;

    }


}

SymbolTable::SymbolTable(int bucketLength)
{
    this->bucketLength = bucketLength;
    current = new ScopeTable(bucketLength);
    tableNo =1;
    current->setParent(0);
}

bool SymbolTable::enterScope()
{

    ScopeTable *child = new ScopeTable(bucketLength);
    child->setParent(current);
    current = child;
    tableNo++;
    //cout<<"New ScopeTable with id "<<tableNo<<" created"<<endl<<endl;
    return true;
}

bool SymbolTable::exitScope()
{
    if(current!=0)
    {
        ScopeTable* parent = current->getParent();
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        current->~ScopeTable();
        //cout<<"ScopeTable with id "<<tableNo<<" remove"<<endl<<endl;
        current=parent;
        tableNo--;
        return true;
    }
    else
        return false;

}

bool SymbolTable::insertion(SymbolInfo* entry)
{
    int result = current->insertion(entry);
    if(result==true)
    {
        //cout<<"Inserted in ScopeTable# "<<tableNo<<" ";
        current->printPosition(entry->getSymbol());
    }
    else
    {
        //cout<<"already exists"<<endl<<endl;
    }
    return result;

}

bool SymbolTable::removal(string symbol)
{
    bool result = current->lookUp(symbol);
    if(result==true)
    {
        //cout<<"deleted entry from current ScopeTable ";
        current->printPosition(symbol);
        current->deletion(symbol);
    }
    else
    {
        //cout<<"not found"<<endl<<endl;

    }
    return result;



}

SymbolInfo* SymbolTable::lookUp(string symbol)
{
    ScopeTable * temp = current;
    SymbolInfo * found =0;
    int tablenumber = tableNo;
    while(temp!=0)
    {
        found =temp->lookUp(symbol);
        if(found!=0)
        {
            //cout<<"found in ScopeTable# "<<tablenumber<<" ";
            temp->printPosition(symbol);
            break;
        }
        temp = temp->getParent();
        tablenumber--;
    }
    if(found==0)
    {
        //cout<<"not found"<<endl<<endl;
    }
    return found;
}

void SymbolTable::printCurrent()
{
    //cout<<"ScopeTable# "<<tableNo<<endl<<endl;
    current->print();
}

void SymbolTable::printAll()
{
    int tablenumber = tableNo;
    ScopeTable* temp = current;
    while(temp!=0)
    {
        //cout<<"ScopeTable# "<<tablenumber<<endl<<endl;
        temp->print();
        temp = temp->getParent();
    }
}
*/