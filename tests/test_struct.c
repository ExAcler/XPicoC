struct a {
    int aa;
    int *aaa;
    int bb;
    int *bbb;
    int cc;
};

void SetValue(struct a *input)
{
    input->aa = 5;
    input->bb = 6;
    input->cc = 7;
    input->aaa = &(input->aa);
    input->bbb = &(input->bb);
    int prn = *(input->aaa);
}

void SetValueNoPointer(struct a input)
{
    int prn = *(input.aaa);
    prn = *(input.bbb);
}

struct a str;
SetValue(&str);
SetValueNoPointer(str);

int prn = str.aa;
prn = str.bb;
prn = str.cc;