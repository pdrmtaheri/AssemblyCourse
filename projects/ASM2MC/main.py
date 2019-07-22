import sys

from exceptions import InvalidInstructionException
from operation_translator import Instruction, MachineCode

if __name__ == '__main__':
    for inp in sys.stdin:
        try:
            instruction = Instruction(inp)
            code = MachineCode(instruction).build_machine_code()
            print(code)
            machine_code = hex(int(code.replace(' ', ''), 2))
            print(machine_code)
        except InvalidInstructionException as e:
            print("Invalid instruction, error : {}".format(e))
