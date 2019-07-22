def is_numeric(s):
    if (s.startswith('0x')) or s.isdigit() or s[0] == '-':
        return True

    return False


def convert_to_binary(s):
    if s.startswith('0x'):
        res = bin(int(s, 16))[2:]
    else:
        res = bin(int(s, 10))[2:]

    if len(res) <= 8:
        return ('0' * 8 + res)[-8:]
    elif len(res) <= 32:
        return ('0' * 32 + res)[-32:]
