// Child-only schema. Functions are included separately inside each consumer.
`ifndef GAUSSIAN_CONTRACT_VH
`define GAUSSIAN_CONTRACT_VH
`define GAUSS_NONE 2'd0
`define GAUSS_MED 2'd1
`define GAUSS_GAU 2'd2
`define GAUSS_INVALID 2'd3
`define GAUSS_CONFIG(g,w,h,hi,lo,f) gauss_config(g,w,h,hi,lo,f)
`endif
