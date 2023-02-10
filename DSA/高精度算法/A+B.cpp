#include <iostream>
#include <string>
using namespace std;
#define N 520
int a[N], b[N], c[N] = { 0 };
int main() {
	string A, B;
	cin >> A >> B;
	int len = A.length() > B.length() ? A.length() : B.length();
	for (int i = A.length() - 1, j = 0; i >= 0; i--, j++) {
		a[j] = A[i] - '0';//必须从低位到高位进行处理，故而j=1，i=l-1；char转int要减0
	}
	for (int i = B.length() - 1, j = 0; i >= 0; i--, j++) {
		b[j] = B[i] - '0';
	}
	for (int i = 0; i <= len - 1; i++) {
		c[i] += a[i] + b[i];
		c[i + 1] += c[i] / 10;
		c[i] %= 10;
	}//for循环不够熟练
	if (c[len])len++;
	for (int i = len - 1; i >= 0; i--) {
		cout << c[i];
	}
	cout << endl;
	return 0;
}