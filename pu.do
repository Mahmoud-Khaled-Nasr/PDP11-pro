vsim work.pu
# End time: 17:38:25 on Dec 15,2017, Elapsed time: 0:10:53
# Errors: 5, Warnings: 2
# vsim work.pu 
# Start time: 17:38:25 on Dec 15,2017
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.std_logic_arith(body)
# Loading ieee.std_logic_unsigned(body)
# Loading ieee.numeric_std(body)
# Loading work.my_package
# Loading work.pu(processing_unit)
# Loading work.alu(alu_arch)
# Loading work.register_address_decoder(register_address_decoder_arch)
# Loading work.register_address_decoder2(register_address_decoder_arch2)
# Loading work.general_register(general_register_arch)
# Loading work.mdr(mdr_arch)
# Loading work.ram(ram_arch)
# Loading work.ir_register(ir_register_arch)
# ** Warning: (vsim-8683) Uninitialized out port /pu/RAM_LAB/MFC has no driver.
# This port will contribute value (U) to the signal network.
# ** Warning: (vsim-8683) Uninitialized out port /pu/RAM_LAB/MDR_READ has no driver.
# This port will contribute value (U) to the signal network.
add wave sim:/pu/*
add wave sim:/pu/CONTROL_UNIT/*
mem load -i ./RAM.mem -filltype value -filldata RAM -fillradix symbolic -skip 0 -update_properties /pu/RAM_LAB/MEMORY
