#include<iostream>
#include<stdlib.h>
#include<stdio.h>
using namespace std;

class SymbolInfo
{
    string name;
    string type;
    SymbolInfo* next;

public:

    SymbolInfo* getNext();
    string getSymbol();
    string getType();
    void setSymbol(string symbol);
    void setType(string type);
    void setNext(SymbolInfo* n);
    SymbolInfo();
    SymbolInfo(string name,string type);
    ~SymbolInfo();
};

SymbolInfo::~SymbolInfo()
{
    cout<<"symbol info destructor called"<<endl;
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

class ScopeTable
{
    SymbolInfo **arr;
    ScopeTable *parent;
    int bucketLength;
    int hashFunc(string symbol);
public:
    ScopeTable(int bucketLength);
    void setParent(ScopeTable *p);
    ScopeTable* getParent();
    bool insertion(SymbolInfo *entry);
    SymbolInfo* lookUp(string symbol);
    bool deletion(string symbol);
    void print();
    void printPosition(string symbol);
    ~ScopeTable();
};

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
    cout<<"scopeTable deleted"<<endl;
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
    SymbolInfo *temp = arr[ind];
    //int position = 0;
    while(temp!=0)
    {
        if(temp->getSymbol().compare(symbol)==0)
        {

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
        cout<<i<<"--->  ";
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {
            cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            temp=temp->getNext();
        }
        cout<<endl<<endl;
    }
}
void ScopeTable::printPosition(string symbol)
{
    SymbolInfo *found=lookUp(symbol);
    if(found==0)
    {
        cout<<"not found"<<endl;
        return;
    }


    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    int position = 0;
    while(temp)
    {
        if(temp->getSymbol().compare(symbol)==0)
        {
            cout<<"at position "<<ind<<", "<<position<<endl<<endl;
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

class SymbolTable
{
    ScopeTable *current;
    int tableNo;
    int bucketLength;
public:
    //void getPosition(string symbol);
    SymbolTable(int bucketLength);
    bool enterScope();
    bool exitScope();
    bool insertion(SymbolInfo *entry);
    bool removal(string symbol);
    SymbolInfo* lookUp(string symbol);
    void printCurrent();
    void printAll();
    ~SymbolTable();

};

SymbolTable::~SymbolTable()
{
    cout<<"In symboltable destructor"<<endl;
    ScopeTable* parent ;
    while(current!=0)
    {
        cout<<"calling scope table destructor "<<tableNo<<endl;
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
    cout<<"New ScopeTable with id "<<tableNo<<" created"<<endl<<endl;
    return true;
}

bool SymbolTable::exitScope()
{
    if(current!=0)
    {
        ScopeTable* parent = current->getParent();
        cout<<"calling scope table destructor "<<tableNo<<endl;
        current->~ScopeTable();
        cout<<"ScopeTable with id "<<tableNo<<" remove"<<endl<<endl;
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
        cout<<"Inserted in ScopeTable# "<<tableNo<<" ";
        current->printPosition(entry->getSymbol());
    }
    else
    {
        cout<<"already exists"<<endl<<endl;
    }
    return result;

}

bool SymbolTable::removal(string symbol)
{
    bool result = current->lookUp(symbol);
    if(result==true)
    {
        cout<<"deleted entry from current ScopeTable ";
        current->printPosition(symbol);
        current->deletion(symbol);
    }
    else
    {
        cout<<"not found"<<endl<<endl;

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
            cout<<"found in ScopeTable# "<<tablenumber<<" ";
            temp->printPosition(symbol);
            break;
        }
        temp = temp->getParent();
        tablenumber--;
    }
    if(found==0)
    {
        cout<<"not found"<<endl<<endl;
    }
    return found;
}

void SymbolTable::printCurrent()
{
    cout<<"ScopeTable# "<<tableNo<<endl<<endl;
    current->print();
}

void SymbolTable::printAll()
{
    int tablenumber = tableNo;
    ScopeTable* temp = current;
    while(temp!=0)
    {
        cout<<"ScopeTable# "<<tablenumber<<endl<<endl;
        temp->print();
        temp = temp->getParent();
    }
}

int main()
{

    freopen("input.txt", "r", stdin);
    //freopen("output3.txt", "w", stdout);
    int n;
    cout<<"input bucket length: "<<endl;
    cin>>n;
    SymbolTable t1(n);
    char c[100];
    while(true)
    {
        scanf("%s",c);
        printf("%s ",c);
        //I L D P S E
        if(c[0]=='I')
        {
            scanf("%s",c);
            printf("%s ",c);
            string symbol(c);
            scanf("%s",c);
            printf("%s ",c);
            string type(c);
            cout<<endl<<endl;



            SymbolInfo * t = new SymbolInfo(symbol,type);
            bool result=t1.insertion(t);
            //cout<<endl<<result<<endl<<endl;

        }
        else if(c[0]=='L')
        {
            scanf("%s",c);
            printf("%s ",c);
            string symbol(c);
            cout<<endl<<endl;

            bool result=t1.lookUp(symbol);
            //cout<<endl<<result<<endl<<endl;

        }
        else if(c[0]=='D')
        {
            scanf("%s",c);
            printf("%s ",c);
            string symbol(c);
            cout<<endl<<endl;

            bool result=t1.removal(symbol);
            //cout<<endl<<result<<endl<<endl;
        }
        else if(c[0]=='P')
        {
            scanf("%s",c);
            printf("%s ",c);
            cout<<endl<<endl;
            if(c[0]=='A')
            {
                t1.printAll();
            }
            else
            {
                t1.printCurrent();
            }
            cout<<endl<<endl;


        }
        else if(c[0]=='S')
        {
            cout<<endl<<endl;
            bool result=t1.enterScope();
            //cout<<result<<endl<<endl;
        }
        else if(c[0]=='E')
        {

            cout<<endl<<endl;
            bool result=t1.exitScope();
            //cout<<result<<endl<<endl;
        }
        else
        {
            break;
        }
    }

//    SymbolTable t1(n);
//    SymbolInfo* t2 = new SymbolInfo("a2","b2");
//    SymbolInfo* t3 = new SymbolInfo("a3","b3");
//    SymbolInfo* t4 = new SymbolInfo("a4","b4");
//    t1.insertion(t2);
//    t1.insertion(t3);
//    t1.insertion(t4);
//    t1.printCurrent();
//    t1.printAll();
}



