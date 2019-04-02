from cryptography.fernet import Fernet

key = 'TluxwB3fV_GWuLkR1_BzGs1Zk90TYAuhNMZP_0q4WyM='

# Oh no! The code is going over the edge! What are you going to do?
message = b'gAAAAABcUfBZQZU5nhoGuVKt2OsI1d4CuDm_46H9xMB0Yta5k5Y26QJM4FPqgS5eE75kFu3p_sOVb0o0P9hpNno_Y1h0No2hOMV5hV6VaIxZ1Y6kCXT18EXGes92f8SvxELBCHRJSJWuD6pgfo4Ufef_vpCiOqs71Ewu7Ggvb5cZ2M-M-NDe12M='

def main():
    f = Fernet(key)
    print(f.decrypt(message))

print(__name__)
    

if __name__ == "__main__":
    main()