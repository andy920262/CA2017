module IF_ID
(
	pc_i,
	inst_i,
	harzard_i,
	flush_i,
	pc_o,
	inst_o
);

input	[31:0]	pc_i;
input	[31:0]	inst_i;
input			harzard_i;
