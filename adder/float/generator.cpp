#include<iostream>
#include <random>

using std::cout;

void printTestBenchCode(const int *p, const int *q, const int *r) { //in verilog
    cout << "================= testbench code =================\n";
    cout << "x = 32'h" << std::hex << *p << ";\n";
    cout << "y = 32'h" << std::hex << *q << ";\n";
    cout << "#1000\n$display(\"%b + %b = %b, overflow:%b\", x, y, z, overflow);\n";
    cout << "if (z != 32'h" << std::hex << *r
         << " || overflow != 2'b00) begin\n$display(\"Wrong Answer!\");\n";
    cout << "end\nelse begin\n$display(\"Correct!\");\nend\n";
    cout << std::dec;
}

int main() {
    srand(time(nullptr));
    std::default_random_engine generator(rand());
    std::uniform_real_distribution<float> distribution(-rand(), rand());
    float a = distribution(generator);
    float b = distribution(generator);
    float c = a + b;
    int *p = (int *) (&a);
    int *q = (int *) (&b);
    int *r = (int *) (&c);
    cout << "Random float add equation generated:\n" << a << " + " << b << " = " << c << '\n';
    cout << "in hexadecimal representation:\n" << std::hex << *p << " + " << *q << " = " << *r << '\n';
    printTestBenchCode(p, q, r);
    return 0;
}
