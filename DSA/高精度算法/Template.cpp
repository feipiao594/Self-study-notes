#include <iostream>
#include <cstdio>
#include <vector>

using namespace std;
struct BigInteger
{
    vector<int> s;
    static const int BASE = 10000;
    static const int WIDTH = 4;
    void standardize()
    {
        for (   int i = s.size() - 1; i >= 0; --i)
        {
            if (s[i] == 0)
                s.pop_back();
            else
                break;
        }
        if (s.empty())
            s.push_back(0);
    }

    BigInteger& operator = (long long num)
    {
        s.clear();
        do
        {
            s.push_back(num % BASE);
            num /= BASE;
        } while (num > 0);
        return *this;
    }
    BigInteger& operator = (const string& num)
    {
        s.clear();
        int len = (num.size() - 1) / WIDTH + 1;
        int x = 0;
        for (int i = 0; i < len; ++i)
        {
            int end = num.size() - i * WIDTH;
            int start = max(0, end - WIDTH);
            sscanf(num.substr(start, end - start).c_str(), "%d", &x);
            s.push_back(x);
        }
        standardize();
        return *this;
    }
    BigInteger operator + (const BigInteger& rhs) const
    {
        int size = max(s.size(), rhs.s.size());
        int carry = 0;
        BigInteger ans;
        for (int i = 0; i < size; ++i)
        {
            int sum = carry;
            if (i < s.size()) sum += s[i];
            if (i < rhs.s.size()) sum += rhs.s[i];
            carry = sum / BASE;
            ans.s.push_back(sum % BASE);
        }
        if (carry > 0)
        {
            ans.s.push_back(carry);
        }
        return ans;
    }
    BigInteger operator * (const BigInteger& rhs) const
    {
        BigInteger ans;
        for (int i = 0; i < rhs.s.size(); ++i)
        {
            BigInteger lans;
            for (int k = 0; k < i; ++k) lans.s.push_back(0);
            int carry = 0;
            for (int j = 0; j < s.size(); ++j)
            {
                int result = rhs.s[i] * s[j] + carry;
                carry = result / BASE;
                lans.s.push_back(result % BASE);
            }
            while (carry > 0)
            {
                lans.s.push_back(carry % BASE);
                carry /= BASE;
            }
            ans = ans + lans;
        }
        return ans;
    }
    BigInteger operator - (const BigInteger& rhs) const
    {
        BigInteger ans;
        int carry = 0;
        for (int i = 0; i < s.size(); ++i)
        {
            int diff = s[i] - carry;
            if (i < rhs.s.size()) diff -= rhs.s[i];
            carry = 0;
            while (diff < 0)
            {
                ++carry;
                diff += BASE;
            }
            ans.s.push_back(diff);
        }
        ans.standardize();
        return ans;
    }
    BigInteger operator / (int rhs) const
    {
        BigInteger ans;
        vector<int> t;
        long long rmder = 0;
        for (int i = s.size() - 1; i >= 0; --i)
        {
            long long temp = rmder * BASE + s[i];
            long long div = temp / rhs;
            rmder = temp % rhs;
            t.push_back(div);
        }
        for (int i = t.size() - 1; i >= 0; --i)
            ans.s.push_back(t[i]);
        ans.standardize();
        return ans;
    }

    friend ostream& operator << (ostream& out, const BigInteger& rhs)
    {
        out << rhs.s.back();
        for (int i = rhs.s.size() - 2; i >= 0; --i)
        {
            char buf[5];
            sprintf(buf, "%04d", rhs.s[i]);
            cout << string(buf);
        }
        return out;
    }
    bool operator < (const BigInteger& rhs) const
    {
        if (s.size() != rhs.s.size()) return s.size() < rhs.s.size();
        for (int i = s.size() - 1; i >= 0; --i)
        {
            if (s[i] != rhs.s[i])
                return s[i] < rhs.s[i];
        }
        return false;
    }
};
//The function below need more tests.
//This function is generally the most difficult. Meanwhile, that means it is rarely used.
BigInteger operator / (const BigInteger& a, const BigInteger& b)
{
    BigInteger rmder, x, xbk, rslt;
    rmder = a;
    x = xbk = b;
    int baseNum = 0;
    while (1)
    {
        x = x * 10;
        if (x < rmder)
        {
            ++baseNum;
            xbk = x;
            continue;
        }

        int div = 0;
        while (xbk <= rmder)
        {
            ++div;
            rmder = rmder - xbk;
        }
        if (div == 0)
            break;

        BigInteger t;
        for (int i = 0; i < baseNum; ++i)
        {
            t.number.push_back(0);
        }
        t.number.push_back(div);
        rslt = rslt + t;

        baseNum = 0;
        x = xbk = b;
    }
    rslt.rmZero();
    return rslt;
}
int main()
{
    BigInteger A, B, C, D;
    A = "100";
    B = 1;
    int t = 10;
    cout << A << endl;
    cout << B << endl;
    cout << t << endl;
    cout << "A+B:" << A + B << endl;
    if (B < A)
        cout << "A-B:" << A - B << endl;
    else
        cout << "B-A:" << B - A << endl;
    cout << "A*B:" << A * B << endl;
    cout << "A/t:" << A / t << endl;
    return 0;
}