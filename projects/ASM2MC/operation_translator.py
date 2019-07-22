from enum import Enum

from constants import register_dict, operand_size_dict, reg_size_dict, opcode_dict, scale_dict
from exceptions import InvalidInstructionException
from utils import is_numeric, convert_to_binary


class Operation(Enum):
    ADD = 'add'
    SUB = 'sub'
    AND = 'and'
    OR = 'or'
    div = 'div'


class OperandType(Enum):
    REG = 'register'
    MEM = 'memory'
    CON = 'constant'


class OperandPosition(Enum):
    FIRST = 'first'
    SECOND = 'second'


class Operand(object):
    def __init__(self, operand_str, position_str):
        self.str = operand_str
        self.position = OperandPosition(position_str)
        self.type = None
        self.size_specifier_str = None
        self.size = None
        # print(self.str)

        self._validate()
        self._determine_type()
        self._determine_size()

        # print("OP: {}, {}".format(self.size, self.type))

    def _determine_type(self):
        tokens = self.str.split(' ')
        if tokens[0] in operand_size_dict:
            self.str = tokens[1]
            self.size_specifier_str = tokens[0]

        if '[' in self.str:
            if ']' in self.str:
                self.type = OperandType.MEM
            else:
                raise InvalidInstructionException("Expected ']'")
        elif is_numeric(self.str):
            self.type = OperandType.CON
        elif self.str in register_dict:
            self.type = OperandType.REG
        else:
            raise InvalidInstructionException("Unknown operand: {}".format(self.str))

    def _validate(self):
        if is_numeric(self.str) and self.position == OperandPosition.FIRST:
            raise InvalidInstructionException("First operand cannot be a number")

    def _determine_size(self):
        if self.type == OperandType.REG:
            self.size = reg_size_dict[self.str]
        elif self.size_specifier_str and self.size_specifier_str in operand_size_dict:
            self.size = operand_size_dict[self.size_specifier_str]
        elif self.type == OperandType.MEM or self.type == OperandType.CON:
            self.size = -1
        else:
            raise InvalidInstructionException("No one should encounter this, really")


class Instruction(object):
    def __init__(self, instruction_str):
        self.instruction_str = instruction_str.lower().strip().replace('ptr', '')
        self._extract_operation()
        self._extract_operands()
        self._determine_size()

        # print("Instruction: {}, {}".format(self.operation, self.size))

    def _extract_operation(self):
        try:
            self.operation = Operation(self.instruction_str.split(' ')[0].strip())
        except ValueError:
            raise InvalidInstructionException("Unsupported operation")

    def _extract_operands(self):
        tokens = self.instruction_str.split(',')
        if len(tokens) != 2:
            raise InvalidInstructionException("Could not determine operands")

        self.operand_1 = Operand(tokens[0].split(' ')[1].strip(), 'first')
        self.operand_2 = Operand(tokens[1].strip(), 'second')

    def _determine_size(self):
        if self.operand_1.size == self.operand_2.size == -1:
            raise InvalidInstructionException("Operation size not specified")
        elif self.operand_1.size == -1:
            self.size = self.operand_2.size
        elif self.operand_2.size == -1:
            self.size = self.operand_1.size
        elif self.operand_1.size != self.operand_2.size:
            raise InvalidInstructionException("Operand sizes do not match")
        else:
            self.size = self.operand_1.size


class MachineCode(object):
    def __init__(self, instruction):
        self.instruction = instruction
        self.op_1, self.op_2 = self.instruction.operand_1, self.instruction.operand_2
        self.scale = ''
        self.index = ''
        self.base = ''
        self.displacement = ''
        self._validate()

    def _validate(self):
        if self.instruction.operand_1.type == OperandType.MEM and self.instruction.operand_2.type == OperandType.MEM:
            raise InvalidInstructionException("Both operands are memory")

    def build_machine_code(self):
        self._build_prefix()
        # print(self.prefix)
        self._build_opcode()
        # print(self.opcode)
        self._build_mod_rm()
        # print('stuff', self.scale, self.index, self.base, self.displacement, self.mod, self.rm)
        self._build_data()

        return self.prefix + ' ' + self.opcode + self.d + self.w + ' ' + self.mod + self.reg + self.rm + ' ' + self.scale + self.index + \
               self.base + ' ' + self.displacement + self.data

    def _build_prefix(self):
        self.address_prefix = ''
        if self.instruction.size != 32:
            self.address_prefix = '01100111'
        self.operand_prefix = ''
        if self.instruction.size == 16:
            self.operand_prefix = '01100110'
        self.prefix = self.address_prefix + self.operand_prefix

    def _build_opcode(self):
        self.opcode = opcode_dict[self.instruction.operation.value]

        self.d = '0'
        if self.op_1.type == OperandType.REG and self.op_2.type == OperandType.MEM:
            self.d = '1'

        self.w = '1'
        if self.instruction.size == 8:
            self.w = '0'

    def _build_mod(self):
        if self.op_1.type == self.op_2.type == OperandType.REG:
            self.mod = '11'
        elif self.displacement == '':
            self.mod = '00'
        elif len(self.displacement) == 8:
            self.mod = '01'
        elif len(self.displacement) == self.instruction.size:
            self.mod = '10'
        else:
            raise InvalidInstructionException("Bad displacement")

    def _build_data(self):
        self.data = ''

    def _build_sib(self, mem_op):
        op_str = mem_op.str.replace('[', '').replace(']', '')
        for p in op_str.split('+'):
            p = p.strip()
            if '*' not in p:
                if p in register_dict:
                    self.base = register_dict[p]
                else:
                    self.displacement = convert_to_binary(p)
                continue
            for p2 in p.split('*'):
                p2 = p2.strip()
                try:
                    if p2 in register_dict:
                        self.index = register_dict[p2]
                    else:
                        self.scale = scale_dict[p2]
                except KeyError as e:
                    raise InvalidInstructionException(e)

    def _build_mod_rm(self):
        if self.op_1.type == self.op_2.type == OperandType.REG:
            self.reg = register_dict[self.op_2.str]
        elif self.op_1.type == OperandType.REG:
            self.reg = register_dict[self.op_1.str]
            if self.op_2.type == OperandType.MEM:
                self._build_sib(self.op_2)
        elif self.op_2.type == OperandType.REG:
            self.reg = register_dict[self.op_2.str]
            if self.op_1.type == OperandType.MEM:
                self._build_sib(self.op_1)

        self._build_mod()
        self._build_rm()

    def _build_rm(self):
        if self.op_1.type == self.op_2.type == OperandType.REG:
            self.rm = register_dict[self.op_1.str]
        if self.displacement != '' and self.index != '':
            self.base = '101'
            self.rm = '100'
            self.mod = '00'
        elif self.displacement != '' and self.base == '' and self.index == '':
            self.rm = '101'
            self.mod = '00'
        elif self.index != '' and self.base != '':
            self.rm = '100'
            self.mod = '00'
        elif self.base:
            self.rm = self.base
            self.base = ''
        else:
            self.rm = register_dict[self.op_1.str]
