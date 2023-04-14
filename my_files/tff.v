module tff(q, t, clk, en, clr);
    //Inputs
    input t, clk, en, clr;

    //Internal wire
    wire dffQ, notDffQ, notT;
    assign notDffQ = ~dffQ;
    assign notT = ~t;

    wire qAndNotT, notQandT, xorAnds;
    assign qAndNotT = notT & dffQ;
    assign notQandT = t & notDffQ;
    assign xorAnds = qAndNotT ^ notQandT;
    //Output
    output q;
    dffe_ref dff(dffQ, xorAnds, clk, en, clr);
    assign q = dffQ;
endmodule