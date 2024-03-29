register_dict = {
    'eax': '000',
    'ax': '000',
    'al': '000',
    'ah': '100',

    'ebx': '011',
    'bx': '011',
    'bl': '011',
    'bh': '111',

    'ecx': '001',
    'cx': '001',
    'cl': '001',
    'ch': '101',

    'edx': '010',
    'dx': '010',
    'dl': '010',
    'dh': '110',

    'esp': '100',
    'ebp': '101',
    'esi': '110',
    'edi': '111'
}

reg_size_dict = {
    'eax': 32,
    'ax': 32,
    'al': 8,
    'ah': 8,

    'ebx': 32,
    'bx': 32,
    'bl': 8,
    'bh': 8,

    'ecx': 32,
    'cx': 32,
    'cl': 8,
    'ch': 8,

    'edx': 32,
    'dx': 32,
    'dl': 8,
    'dh': 8,

    'esp': 32,
    'ebp': 32,
    'esi': 32,
    'edi': 32
}

operand_sizes = ['byte', 'word', 'dword']

operand_size_dict = {
    'byte': 8,
    'word': 16,
    'dword': 32,
}

opcode_dict = {
    'add': '000000',
    # 'add': {'rr': '0000000w', 'mr': '0000000w', 'rm': '0000001w', 'rd': '1000000w', 'md': '1000000w', 'op': '000'},
    # 'sub': {'rr': '0010100w', 'mr': '0010100w', 'rm': '0010101w', 'rd': '1000001w', 'md': '1000001w', 'op': '101'},
    # 'and': {'rr': '0011000w', 'mr': '0011000w', 'rm': '0011001w', 'rd': '1000001w', 'md': '1000001w', 'op': '110'},
}

scale_dict = {
    '1': '00',
    '2': '01',
    '4': '10',
    '8': '11'
}
