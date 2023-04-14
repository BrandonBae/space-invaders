module sr_latch(Q, notQ, S, R);
    //Inputs
    input S, R;
    output Q, notQ;

    wire r_res, s_res;
    nor rNor(r_res, R, s_res);
    nor sNor(s_res, S, r_res);

    assign Q = r_res;
    assign notQ = s_res;
endmodule