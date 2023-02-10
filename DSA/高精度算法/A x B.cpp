#include <iostream>
#include <string>
using namespace std;
#define N 520
int a[N], b[N], c[N] = { 0 };
int main() {
	string A, B;
	cin >> A >> B;
	int len = A.length() + B.length();
	for (int i = A.length() - 1, j = 0; i >= 0; i--, j++)a[j] = A[i] - '0';
	for (int i = B.length() - 1, j = 0; i >= 0; i--, j++)b[j] = B[i] - '0';
	for (int j = 0; j <= A.length() - 1; j++) {
		for (int i = 0; i <= B.length() - 1; i++) {
			c[j + i] += a[j] * b[i];//计算贡献，位于i+j上，注意这里的i和j后面都有数组所带的-1
		}
	}//for循环不够熟练
	for (int i = 0; i <= len - 1; i++) {//转换到加法就是把贡献放到这里算
		c[i + 1] += c[i] / 10;
		c[i] %= 10;
	}
	for (; !c[len - 1] && len > 1; len--);//加法里只需考虑一次，无需循环
	for (int i = len - 1; i >= 0; i--) {
		cout << c[i];
	}
	cout << endl;
	return 0;
}