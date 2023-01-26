`define sh_f    32'd370
`define sh_c    32'd277
`define sh_g    32'd415
`define a       32'd440
`define b       32'd494
`define sh_e    32'd349
`define sh_hc   32'd554

`define sil   32'd50000000 // slience

module music_example (
	input [11:0] ibeatNum,
	input en,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);

    always @* begin
        if(en == 1) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneR = `sh_f;    12'd1: toneR = `sh_f;    
                12'd2: toneR = `sh_f;    12'd3: toneR = `sh_f;    
                12'd4: toneR = `sh_f;    12'd5: toneR = `sh_f;    
                12'd6: toneR = `sh_f;    12'd7: toneR = `sh_f;    
                12'd8: toneR = `sh_f;    12'd9: toneR = `sh_f;    
                12'd10: toneR = `sh_f;   12'd11: toneR = `sh_f;   
                12'd12: toneR = `sh_f;   12'd13: toneR = `sh_f;   
                12'd14: toneR = `sh_f;   12'd15: toneR = `sh_f;   
                
                12'd16: toneR = `sh_c;   12'd17: toneR = `sh_c;   
                12'd18: toneR = `sh_c;   12'd19: toneR = `sh_c;   
                12'd20: toneR = `sh_c;   12'd21: toneR = `sil;    
                12'd22: toneR = `sh_c;   12'd23: toneR = `sh_c;   
                12'd24: toneR = `sh_c;   12'd25: toneR = `sh_c;   
                12'd26: toneR = `sil;    12'd27: toneR = `sh_c;   
                12'd28: toneR = `sh_c;   12'd29: toneR = `sh_c;   
                12'd30: toneR = `sh_c;   12'd31: toneR = `sh_c;   
                
                12'd32: toneR = `sh_f;   12'd33: toneR = `sh_f;   
                12'd34: toneR = `sh_f;   12'd35: toneR = `sh_f;   
                12'd36: toneR = `sh_f;   12'd37: toneR = `sh_f;   
                12'd38: toneR = `sh_f;   12'd39: toneR = `sh_f;   
                12'd40: toneR = `sh_f;   12'd41: toneR = `sh_f;   
                12'd42: toneR = `sh_f;   12'd43: toneR = `sh_f;   
                12'd44: toneR = `sh_f;   12'd45: toneR = `sh_f;   
                12'd46: toneR = `sh_f;   12'd47: toneR = `sil;    
                
                12'd48: toneR = `sh_f;   12'd49: toneR = `sh_f;   
                12'd50: toneR = `sh_f;   12'd51: toneR = `sh_f;   
                12'd52: toneR = `sh_f;   12'd53: toneR = `sh_f;   
                12'd54: toneR = `sh_g;   12'd55: toneR = `sh_g;   
                12'd56: toneR = `sh_g;   12'd57: toneR = `sh_g;   
                12'd58: toneR = `sh_g;   12'd59: toneR = `a;      
                12'd60: toneR = `a;      12'd61: toneR = `a;      
                12'd62: toneR = `a;      12'd63: toneR = `a;      
                
                12'd64: toneR = `sh_g;   12'd65: toneR = `sh_g;   
                12'd66: toneR = `sh_g;   12'd67: toneR = `sh_g;   
                12'd68: toneR = `sh_g;   12'd69: toneR = `sh_g;   
                12'd70: toneR = `sh_g;   12'd71: toneR = `sh_g;   
                12'd72: toneR = `sh_g;   12'd73: toneR = `sh_g;   
                12'd74: toneR = `sh_g;   12'd75: toneR = `sh_g;   
                12'd76: toneR = `sh_g;   12'd77: toneR = `sh_g;   
                12'd78: toneR = `sh_g;   12'd79: toneR = `sh_g;   
                
                12'd80: toneR = `sh_c;   12'd81: toneR = `sh_c;   
                12'd82: toneR = `sh_c;   12'd83: toneR = `sh_c;   
                12'd84: toneR = `sh_c;   12'd85: toneR = `sil;    
                12'd86: toneR = `sh_c;   12'd87: toneR = `sh_c;   
                12'd88: toneR = `sh_c;   12'd89: toneR = `sh_c;   
                12'd90: toneR = `sil;    12'd91: toneR = `sh_c;   
                12'd92: toneR = `sh_c;   12'd93: toneR = `sh_c;   
                12'd94: toneR = `sh_c;   12'd95: toneR = `sh_c;   
                
                12'd96: toneR = `sh_g;   12'd97: toneR = `sh_g;   
                12'd98: toneR = `sh_g;   12'd99: toneR = `sh_g;   
                12'd100: toneR = `sh_g;  12'd101: toneR = `sh_g;  
                12'd102: toneR = `sh_g;  12'd103: toneR = `sh_g;  
                12'd104: toneR = `sh_g;  12'd105: toneR = `sh_g;  
                12'd106: toneR = `sh_g;  12'd107: toneR = `sh_g;  
                12'd108: toneR = `sh_g;  12'd109: toneR = `sh_g;  
                12'd110: toneR = `sh_g;  12'd111: toneR = `sil;   
                
                12'd112: toneR = `sh_g;  12'd113: toneR = `sh_g;  
                12'd114: toneR = `sh_g;  12'd115: toneR = `sh_g;  
                12'd116: toneR = `sh_g;  12'd117: toneR = `sh_g;  
                12'd118: toneR = `a;     12'd119: toneR = `a;     
                12'd120: toneR = `a;     12'd121: toneR = `a;     
                12'd122: toneR = `a;     12'd123: toneR = `b;     
                12'd124: toneR = `b;     12'd125: toneR = `b;     
                12'd126: toneR = `b;     12'd127: toneR = `b;     
                
                12'd128: toneR = `a;     12'd129: toneR = `a;     
                12'd130: toneR = `a;     12'd131: toneR = `a;     
                12'd132: toneR = `a;     12'd133: toneR = `a;     
                12'd134: toneR = `a;     12'd135: toneR = `a;     
                12'd136: toneR = `a;     12'd137: toneR = `a;     
                12'd138: toneR = `a;     12'd139: toneR = `a;     
                12'd140: toneR = `a;     12'd141: toneR = `a;     
                12'd142: toneR = `a;     12'd143: toneR = `a;     
                
                12'd144: toneR = `sh_f;  12'd145: toneR = `sh_f;  
                12'd146: toneR = `sh_f;  12'd147: toneR = `sh_f;  
                12'd148: toneR = `sh_f;  12'd149: toneR = `sil;   
                12'd150: toneR = `sh_f;  12'd151: toneR = `sh_f;  
                12'd152: toneR = `sh_f;  12'd153: toneR = `sh_f;  
                12'd154: toneR = `sil;   12'd155: toneR = `sh_f;  
                12'd156: toneR = `sh_f;  12'd157: toneR = `sh_f;  
                12'd158: toneR = `sh_f;  12'd159: toneR = `sh_f;  
                
                12'd160: toneR = `a;     12'd161: toneR = `a;     
                12'd162: toneR = `a;     12'd163: toneR = `a;     
                12'd164: toneR = `a;     12'd165: toneR = `a;     
                12'd166: toneR = `a;     12'd167: toneR = `a;     
                12'd168: toneR = `a;     12'd169: toneR = `a;     
                12'd170: toneR = `a;     12'd171: toneR = `a;     
                12'd172: toneR = `a;     12'd173: toneR = `a;     
                12'd174: toneR = `a;     12'd175: toneR = `a;     
                
                12'd176: toneR = `sh_f;  12'd177: toneR = `sh_f;  
                12'd178: toneR = `sh_f;  12'd179: toneR = `sh_f;  
                12'd180: toneR = `sh_f;  12'd181: toneR = `sh_f;  
                12'd182: toneR = `sh_g;  12'd183: toneR = `sh_g;  
                12'd184: toneR = `sh_g;  12'd185: toneR = `sh_g;  
                12'd186: toneR = `sh_g;  12'd187: toneR = `sh_f;  
                12'd188: toneR = `sh_f;  12'd189: toneR = `sh_f;  
                12'd190: toneR = `sh_f;  12'd191: toneR = `sil;   
                
                12'd192: toneR = `sh_f;  12'd193: toneR = `sh_f;  
                12'd194: toneR = `sh_f;  12'd195: toneR = `sh_f;  
                12'd196: toneR = `sh_f;  12'd197: toneR = `sh_f;  
                12'd198: toneR = `sh_f;  12'd199: toneR = `sh_f;  
                12'd200: toneR = `sh_f;  12'd201: toneR = `sh_f;  
                12'd202: toneR = `sh_f;  12'd203: toneR = `sh_f;  
                12'd204: toneR = `sh_f;  12'd205: toneR = `sh_f;  
                12'd206: toneR = `sh_f;  12'd207: toneR = `sh_f;  
                
                12'd208: toneR = `sil;   12'd209: toneR = `sil;   
                12'd210: toneR = `sil;   12'd211: toneR = `sil;   
                12'd212: toneR = `sil;   12'd213: toneR = `sil;   
                12'd214: toneR = `sh_g;  12'd215: toneR = `sh_g;  
                12'd216: toneR = `sh_g;  12'd217: toneR = `sh_g;  
                12'd218: toneR = `sh_g;  12'd219: toneR = `sh_f;  
                12'd220: toneR = `sh_f;  12'd221: toneR = `sh_f;  
                12'd222: toneR = `sh_f;  12'd223: toneR = `sh_f;  
                
                12'd224: toneR = `sh_e;  12'd225: toneR = `sh_e;  
                12'd226: toneR = `sh_e;  12'd227: toneR = `sh_e;  
                12'd228: toneR = `sh_e;  12'd229: toneR = `sh_e;  
                12'd230: toneR = `sh_e;  12'd231: toneR = `sh_e;  
                12'd232: toneR = `sh_e;  12'd233: toneR = `sh_e;  
                12'd234: toneR = `sh_e;  12'd235: toneR = `sh_e;  
                12'd236: toneR = `sh_e;  12'd237: toneR = `sh_e;  
                12'd238: toneR = `sh_e;  12'd239: toneR = `sh_e;  
                
                12'd240: toneR = `sh_e;  12'd241: toneR = `sh_e;  
                12'd242: toneR = `sh_e;  12'd243: toneR = `sh_e;  
                12'd244: toneR = `sh_e;  12'd245: toneR = `sh_e;  
                12'd246: toneR = `sh_f;  12'd247: toneR = `sh_f;  
                12'd248: toneR = `sh_f;  12'd249: toneR = `sh_f;  
                12'd250: toneR = `sh_f;  12'd251: toneR = `sh_g;  
                12'd252: toneR = `sh_g;  12'd253: toneR = `sh_g;  
                12'd254: toneR = `sh_g;  12'd255: toneR = `sh_g;  
                
                12'd256: toneR = `sh_f;  12'd257: toneR = `sh_f;  
                12'd258: toneR = `sh_f;  12'd259: toneR = `sh_f;  
                12'd260: toneR = `sh_f;  12'd261: toneR = `sh_f;  
                12'd262: toneR = `sh_f;  12'd263: toneR = `sh_f;  
                12'd264: toneR = `sh_f;  12'd265: toneR = `sh_f;  
                12'd266: toneR = `sh_f;  12'd267: toneR = `sh_f;  
                12'd268: toneR = `sh_f;  12'd269: toneR = `sh_f;  
                12'd270: toneR = `sh_f;  12'd271: toneR = `sh_f;  
                
                12'd272: toneR = `sh_c;  12'd273: toneR = `sh_c;  
                12'd274: toneR = `sh_c;  12'd275: toneR = `sh_c;  
                12'd276: toneR = `sh_c;  12'd277: toneR = `sil;   
                12'd278: toneR = `sh_c;  12'd279: toneR = `sh_c;  
                12'd280: toneR = `sh_c;  12'd281: toneR = `sh_c;  
                12'd282: toneR = `sil;   12'd283: toneR = `sh_c;  
                12'd284: toneR = `sh_c;  12'd285: toneR = `sh_c;  
                12'd286: toneR = `sh_c;  12'd287: toneR = `sh_c;  
                
                12'd288: toneR = `sh_f;  12'd289: toneR = `sh_f;  
                12'd290: toneR = `sh_f;  12'd291: toneR = `sh_f;  
                12'd292: toneR = `sh_f;  12'd293: toneR = `sh_f;  
                12'd294: toneR = `sh_f;  12'd295: toneR = `sh_f;  
                12'd296: toneR = `sh_f;  12'd297: toneR = `sh_f;  
                12'd298: toneR = `sh_f;  12'd299: toneR = `sh_f;  
                12'd300: toneR = `sh_f;  12'd301: toneR = `sh_f;  
                12'd302: toneR = `sh_f;  12'd303: toneR = `sil;   
                
                12'd304: toneR = `sh_f;  12'd305: toneR = `sh_f;  
                12'd306: toneR = `sh_f;  12'd307: toneR = `sh_f;  
                12'd308: toneR = `sh_f;  12'd309: toneR = `sh_f;  
                12'd310: toneR = `sh_g;  12'd311: toneR = `sh_g;  
                12'd312: toneR = `sh_g;  12'd313: toneR = `sh_g;  
                12'd314: toneR = `sh_g;  12'd315: toneR = `a;     
                12'd316: toneR = `a;     12'd317: toneR = `a;     
                12'd318: toneR = `a;     12'd319: toneR = `a;     
                
                12'd320: toneR = `sh_g;  12'd321: toneR = `sh_g;  
                12'd322: toneR = `sh_g;  12'd323: toneR = `sh_g;  
                12'd324: toneR = `sh_g;  12'd325: toneR = `sh_g;  
                12'd326: toneR = `sh_g;  12'd327: toneR = `sh_g;  
                12'd328: toneR = `sh_g;  12'd329: toneR = `sh_g;  
                12'd330: toneR = `sh_g;  12'd331: toneR = `sh_g;  
                12'd332: toneR = `sh_g;  12'd333: toneR = `sh_g;  
                12'd334: toneR = `sh_g;  12'd335: toneR = `sh_g;  
                
                12'd336: toneR = `sh_c;  12'd337: toneR = `sh_c;  
                12'd338: toneR = `sh_c;  12'd339: toneR = `sh_c;  
                12'd340: toneR = `sh_c;  12'd341: toneR = `sil;   
                12'd342: toneR = `sh_c;  12'd343: toneR = `sh_c;  
                12'd344: toneR = `sh_c;  12'd345: toneR = `sh_c;  
                12'd346: toneR = `sil;   12'd347: toneR = `sh_c;  
                12'd348: toneR = `sh_c;  12'd349: toneR = `sh_c;  
                12'd350: toneR = `sh_c;  12'd351: toneR = `sh_c;  
                
                12'd352: toneR = `sh_g;  12'd353: toneR = `sh_g;  
                12'd354: toneR = `sh_g;  12'd355: toneR = `sh_g;  
                12'd356: toneR = `sh_g;  12'd357: toneR = `sh_g;  
                12'd358: toneR = `sh_g;  12'd359: toneR = `sh_g;  
                12'd360: toneR = `sh_g;  12'd361: toneR = `sh_g;  
                12'd362: toneR = `sh_g;  12'd363: toneR = `sh_g;  
                12'd364: toneR = `sh_g;  12'd365: toneR = `sh_g;  
                12'd366: toneR = `sh_g;  12'd367: toneR = `sil;   
                
                12'd368: toneR = `sh_g;  12'd369: toneR = `sh_g;  
                12'd370: toneR = `sh_g;  12'd371: toneR = `sh_g;  
                12'd372: toneR = `sh_g;  12'd373: toneR = `sh_g;  
                12'd374: toneR = `a;     12'd375: toneR = `a;     
                12'd376: toneR = `a;     12'd377: toneR = `a;     
                12'd378: toneR = `a;     12'd379: toneR = `b;     
                12'd380: toneR = `b;     12'd381: toneR = `b;     
                12'd382: toneR = `b;     12'd383: toneR = `b;     
                
                12'd384: toneR = `a;     12'd385: toneR = `a;     
                12'd386: toneR = `a;     12'd387: toneR = `a;     
                12'd388: toneR = `a;     12'd389: toneR = `a;     
                12'd390: toneR = `a;     12'd391: toneR = `a;     
                12'd392: toneR = `a;     12'd393: toneR = `a;     
                12'd394: toneR = `a;     12'd395: toneR = `a;     
                12'd396: toneR = `a;     12'd397: toneR = `a;     
                12'd398: toneR = `a;     12'd399: toneR = `a;     
                
                12'd400: toneR = `sh_f;  12'd401: toneR = `sh_f;  
                12'd402: toneR = `sh_f;  12'd403: toneR = `sh_f;  
                12'd404: toneR = `sh_f;  12'd405: toneR = `sil;   
                12'd406: toneR = `sh_f;  12'd407: toneR = `sh_f;  
                12'd408: toneR = `sh_f;  12'd409: toneR = `sh_f;  
                12'd410: toneR = `sil;   12'd411: toneR = `sh_f;  
                12'd412: toneR = `sh_f;  12'd413: toneR = `sh_f;  
                12'd414: toneR = `sh_f;  12'd415: toneR = `sh_f;  
                
                12'd416: toneR = `a;     12'd417: toneR = `a;     
                12'd418: toneR = `a;     12'd419: toneR = `a;     
                12'd420: toneR = `a;     12'd421: toneR = `a;     
                12'd422: toneR = `a;     12'd423: toneR = `a;     
                12'd424: toneR = `a;     12'd425: toneR = `a;     
                12'd426: toneR = `a;     12'd427: toneR = `a;     
                12'd428: toneR = `a;     12'd429: toneR = `a;     
                12'd430: toneR = `a;     12'd431: toneR = `sil;   
                
                12'd432: toneR = `a;     12'd433: toneR = `a;     
                12'd434: toneR = `a;     12'd435: toneR = `a;     
                12'd436: toneR = `a;     12'd437: toneR = `a;     
                12'd438: toneR = `b;     12'd439: toneR = `b;     
                12'd440: toneR = `b;     12'd441: toneR = `b;     
                12'd442: toneR = `b;     12'd443: toneR = `sh_hc; 
                12'd444: toneR = `sh_hc; 12'd445: toneR = `sh_hc; 
                12'd446: toneR = `sh_hc; 12'd447: toneR = `sh_hc; 
                
                12'd448: toneR = `b;     12'd449: toneR = `b;     
                12'd450: toneR = `b;     12'd451: toneR = `b;     
                12'd452: toneR = `b;     12'd453: toneR = `b;     
                12'd454: toneR = `b;     12'd455: toneR = `b;     
                12'd456: toneR = `b;     12'd457: toneR = `b;     
                12'd458: toneR = `b;     12'd459: toneR = `b;     
                12'd460: toneR = `b;     12'd461: toneR = `b;     
                12'd462: toneR = `b;     12'd463: toneR = `b;     
                
                12'd464: toneR = `sil;   12'd465: toneR = `sil;   
                12'd466: toneR = `sil;   12'd467: toneR = `sil;   
                12'd468: toneR = `sil;   12'd469: toneR = `sil;   
                12'd470: toneR = `sh_f;  12'd471: toneR = `sh_f;  
                12'd472: toneR = `sh_f;  12'd473: toneR = `sh_f;  
                12'd474: toneR = `sil;   12'd475: toneR = `sh_f;  
                12'd476: toneR = `sh_f;  12'd477: toneR = `sh_f;  
                12'd478: toneR = `sh_f;  12'd479: toneR = `sil;   
                
                12'd480: toneR = `sh_f;  12'd481: toneR = `sh_f;  
                12'd482: toneR = `sh_f;  12'd483: toneR = `sh_f;  
                12'd484: toneR = `sh_f;  12'd485: toneR = `sh_f;  
                12'd486: toneR = `sh_f;  12'd487: toneR = `sh_f;  
                12'd488: toneR = `sh_f;  12'd489: toneR = `sh_f;  
                12'd490: toneR = `sh_f;  12'd491: toneR = `sh_f;  
                12'd492: toneR = `sh_f;  12'd493: toneR = `sh_f;  
                12'd494: toneR = `sh_f;  12'd495: toneR = `sh_f;  
                
                12'd496: toneR = `sh_f;  12'd497: toneR = `sh_f;  
                12'd498: toneR = `sh_f;  12'd499: toneR = `sh_f;  
                12'd500: toneR = `sh_f;  12'd501: toneR = `sil;   
                12'd502: toneR = `sh_f;  12'd503: toneR = `sh_f;  
                12'd504: toneR = `sh_f;  12'd505: toneR = `sh_f;  
                12'd506: toneR = `sh_f;  12'd507: toneR = `sh_g;  
                12'd508: toneR = `sh_g;  12'd509: toneR = `sh_g;  
                12'd510: toneR = `sh_g;  12'd511: toneR = `sh_g;  
                
                12'd512: toneR = `a;     12'd513: toneR = `a;     
                12'd514: toneR = `a;     12'd515: toneR = `a;     
                12'd516: toneR = `a;     12'd517: toneR = `a;     
                12'd518: toneR = `a;     12'd519: toneR = `a;     
                12'd520: toneR = `a;     12'd521: toneR = `a;     
                12'd522: toneR = `a;     12'd523: toneR = `a;     
                12'd524: toneR = `a;     12'd525: toneR = `a;     
                12'd526: toneR = `a;     12'd527: toneR = `a;     
                
                12'd528: toneR = `sil;   12'd529: toneR = `sil;   
                12'd530: toneR = `sil;   12'd531: toneR = `sil;   
                12'd532: toneR = `sil;   12'd533: toneR = `sil;   
                12'd534: toneR = `sh_g;  12'd535: toneR = `sh_g;  
                12'd536: toneR = `sh_g;  12'd537: toneR = `sh_g;  
                12'd538: toneR = `sh_g;  12'd539: toneR = `a;     
                12'd540: toneR = `a;     12'd541: toneR = `a;     
                12'd542: toneR = `a;     12'd543: toneR = `a;     
                
                12'd544: toneR = `b;     12'd545: toneR = `b;     
                12'd546: toneR = `b;     12'd547: toneR = `b;     
                12'd548: toneR = `b;     12'd549: toneR = `b;     
                12'd550: toneR = `b;     12'd551: toneR = `b;     
                12'd552: toneR = `b;     12'd553: toneR = `b;     
                12'd554: toneR = `a;     12'd555: toneR = `a;     
                12'd556: toneR = `a;     12'd557: toneR = `a;     
                12'd558: toneR = `a;     12'd559: toneR = `a;     
                
                12'd560: toneR = `a;     12'd561: toneR = `a;     
                12'd562: toneR = `a;     12'd563: toneR = `a;     
                12'd564: toneR = `a;     12'd565: toneR = `sh_g;  
                12'd566: toneR = `sh_g;  12'd567: toneR = `sh_g;  
                12'd568: toneR = `sh_g;  12'd569: toneR = `sh_g;  
                12'd570: toneR = `sh_g;  12'd571: toneR = `sh_g;  
                12'd572: toneR = `sh_g;  12'd573: toneR = `sh_g;  
                12'd574: toneR = `sh_g;  12'd575: toneR = `sh_g;  
                
                12'd576: toneR = `a;     12'd577: toneR = `a;     
                12'd578: toneR = `a;     12'd579: toneR = `a;     
                12'd580: toneR = `a;     12'd581: toneR = `a;     
                12'd582: toneR = `a;     12'd583: toneR = `a;     
                12'd584: toneR = `a;     12'd585: toneR = `a;     
                12'd586: toneR = `a;     12'd587: toneR = `a;     
                12'd588: toneR = `a;     12'd589: toneR = `a;     
                12'd590: toneR = `a;     12'd591: toneR = `a;     
                
                12'd592: toneR = `sil;   12'd593: toneR = `sil;   
                12'd594: toneR = `sil;   12'd595: toneR = `sil;   
                12'd596: toneR = `sil;   12'd597: toneR = `sil;   
                12'd598: toneR = `sh_g;  12'd599: toneR = `sh_g;  
                12'd600: toneR = `sh_g;  12'd601: toneR = `sh_g;  
                12'd602: toneR = `sh_g;  12'd603: toneR = `sh_f;  
                12'd604: toneR = `sh_f;  12'd605: toneR = `sh_f;  
                12'd606: toneR = `sh_f;  12'd607: toneR = `sh_f;  
                
                12'd608: toneR = `sh_g;  12'd609: toneR = `sh_g;  
                12'd610: toneR = `sh_g;  12'd611: toneR = `sh_g;  
                12'd612: toneR = `sh_g;  12'd613: toneR = `sh_g;  
                12'd614: toneR = `sh_g;  12'd615: toneR = `sh_g;  
                12'd616: toneR = `sh_g;  12'd617: toneR = `sh_g;  
                12'd618: toneR = `sh_g;  12'd619: toneR = `sh_g;  
                12'd620: toneR = `sh_g;  12'd621: toneR = `sh_g;  
                12'd622: toneR = `sh_g;  12'd623: toneR = `sh_g;  
                
                12'd624: toneR = `sil;   12'd625: toneR = `sil;   
                12'd626: toneR = `sh_f;  12'd627: toneR = `sh_f;  
                12'd628: toneR = `sh_f;  12'd629: toneR = `sh_f;  
                12'd630: toneR = `sh_f;  12'd631: toneR = `sh_f;  
                12'd632: toneR = `sh_f;  12'd633: toneR = `sh_f;  
                12'd634: toneR = `sh_g;  12'd635: toneR = `sh_g;  
                12'd636: toneR = `sh_g;  12'd637: toneR = `sh_g;  
                12'd638: toneR = `sh_g;  12'd639: toneR = `sh_g;  
                
                12'd640: toneR = `sh_f;  12'd641: toneR = `sh_f;  
                12'd642: toneR = `sh_f;  12'd643: toneR = `sh_f;  
                12'd644: toneR = `sh_f;  12'd645: toneR = `sh_f;  
                12'd646: toneR = `sh_f;  12'd647: toneR = `sh_f;  
                12'd648: toneR = `sh_f;  12'd649: toneR = `sh_f;  
                12'd650: toneR = `sh_f;  12'd651: toneR = `sh_f;  
                12'd652: toneR = `sh_f;  12'd653: toneR = `sh_f;  
                12'd654: toneR = `sh_f;  12'd655: toneR = `sh_f;  
                
                12'd656: toneR = `sh_f;  12'd657: toneR = `sh_f;  
                12'd658: toneR = `sh_f;  12'd659: toneR = `sh_f;  
                12'd660: toneR = `sh_f;  12'd661: toneR = `sh_f;  
                12'd662: toneR = `sh_f;  12'd663: toneR = `sh_f;  
                12'd664: toneR = `sh_f;  12'd665: toneR = `sh_f;  
                12'd666: toneR = `sh_f;  12'd667: toneR = `sh_f;  
                12'd668: toneR = `sh_f;  12'd669: toneR = `sh_f;  
                12'd670: toneR = `sh_f;  12'd671: toneR = `sh_f;  
                
                12'd672: toneR = `sh_f;  12'd673: toneR = `sh_f;  
                12'd674: toneR = `sh_f;  12'd675: toneR = `sh_f;  
                12'd676: toneR = `sh_f;  12'd677: toneR = `sh_f;  
                12'd678: toneR = `sh_f;  12'd679: toneR = `sh_f;  
                12'd680: toneR = `sh_f;  12'd681: toneR = `sh_f;  
                12'd682: toneR = `sh_f;  12'd683: toneR = `sh_f;  
                12'd684: toneR = `sh_f;  12'd685: toneR = `sh_f;  
                12'd686: toneR = `sh_f;  12'd687: toneR = `sh_f;  
                
                12'd688: toneR = `sh_f;  12'd689: toneR = `sh_f;  
                12'd690: toneR = `sh_f;  12'd691: toneR = `sh_f;  
                12'd692: toneR = `sh_f;  12'd693: toneR = `sh_f;  
                12'd694: toneR = `sh_g;  12'd695: toneR = `sh_g;  
                12'd696: toneR = `sh_g;  12'd697: toneR = `sh_g;  
                12'd698: toneR = `sh_g;  12'd699: toneR = `sh_f;  
                12'd700: toneR = `sh_f;  12'd701: toneR = `sh_f;  
                12'd702: toneR = `sh_f;  12'd703: toneR = `sh_f;  
                
                12'd704: toneR = `sh_e;  12'd705: toneR = `sh_e;  
                12'd706: toneR = `sh_e;  12'd707: toneR = `sh_e;  
                12'd708: toneR = `sh_e;  12'd709: toneR = `sh_e;  
                12'd710: toneR = `sh_e;  12'd711: toneR = `sh_e;  
                12'd712: toneR = `sh_e;  12'd713: toneR = `sh_e;  
                12'd714: toneR = `sh_e;  12'd715: toneR = `sh_e;  
                12'd716: toneR = `sh_e;  12'd717: toneR = `sh_e;  
                12'd718: toneR = `sh_e;  12'd719: toneR = `sh_e;  
                
                12'd720: toneR = `sh_e;  12'd721: toneR = `sh_e;  
                12'd722: toneR = `sh_e;  12'd723: toneR = `sh_e;  
                12'd724: toneR = `sh_e;  12'd725: toneR = `sh_e;  
                12'd726: toneR = `sh_e;  12'd727: toneR = `sh_e;  
                12'd728: toneR = `sh_e;  12'd729: toneR = `sh_e;  
                12'd730: toneR = `sh_e;  12'd731: toneR = `sh_e;  
                12'd732: toneR = `sh_e;  12'd733: toneR = `sh_e;  
                12'd734: toneR = `sh_e;  12'd735: toneR = `sh_e;  
                
                12'd736: toneR = `sh_e;  12'd737: toneR = `sh_e;  
                12'd738: toneR = `sh_e;  12'd739: toneR = `sh_e;  
                12'd740: toneR = `sh_e;  12'd741: toneR = `sh_e;  
                12'd742: toneR = `sh_e;  12'd743: toneR = `sh_e;  
                12'd744: toneR = `sh_e;  12'd745: toneR = `sh_e;  
                12'd746: toneR = `sh_e;  12'd747: toneR = `sh_e;  
                12'd748: toneR = `sh_e;  12'd749: toneR = `sh_e;  
                12'd750: toneR = `sh_e;  12'd751: toneR = `sh_e;  
                
                12'd752: toneR = `sh_e;  12'd753: toneR = `sh_e;  
                12'd754: toneR = `sh_e;  12'd755: toneR = `sh_e;  
                12'd756: toneR = `sh_e;  12'd757: toneR = `sh_e;  
                12'd758: toneR = `sh_e;  12'd759: toneR = `sh_e;  
                12'd760: toneR = `sil;   12'd761: toneR = `sil;   
                12'd762: toneR = `sil;   12'd763: toneR = `sil;   
                12'd764: toneR = `sil;   12'd765: toneR = `sil;   
                12'd766: toneR = `sil;   12'd767: toneR = `sil;

                default: toneR = `sil;
            endcase
        end else begin
            toneR = `sil;
        end
    end

    always @(*) begin
        if(en == 1)begin
            case(ibeatNum)
                12'd0: toneL = (`sh_f << 1);       12'd1: toneL = (`sh_f << 1);
                12'd2: toneL = (`sh_f << 1);       12'd3: toneL = (`sh_f << 1);
                12'd4: toneL = (`sh_f << 1);       12'd5: toneL = (`sh_f << 1);
                12'd6: toneL = (`sh_f << 1);       12'd7: toneL = (`sh_f << 1);
                12'd8: toneL = (`sh_f << 1);       12'd9: toneL = (`sh_f << 1);
                12'd10: toneL = (`sh_f << 1);      12'd11: toneL = (`sh_f << 1);
                12'd12: toneL = (`sh_f << 1);      12'd13: toneL = (`sh_f << 1);      
                12'd14: toneL = (`sh_f << 1);      12'd15: toneL = (`sh_f << 1);
                
                12'd16: toneL = (`sh_c << 1);      12'd17: toneL = (`sh_c << 1);
                12'd18: toneL = (`sh_c << 1);      12'd19: toneL = (`sh_c << 1);
                12'd20: toneL = (`sh_c << 1);      12'd21: toneL = `sil;
                12'd22: toneL = (`sh_c << 1);      12'd23: toneL = (`sh_c << 1);
                12'd24: toneL = (`sh_c << 1);      12'd25: toneL = (`sh_c << 1);
                12'd26: toneL = `sil;              12'd27: toneL = (`sh_c << 1);
                12'd28: toneL = (`sh_c << 1);      12'd29: toneL = (`sh_c << 1);
                12'd30: toneL = (`sh_c << 1);      12'd31: toneL = (`sh_c << 1);
                
                12'd32: toneL = (`sh_f << 1);      12'd33: toneL = (`sh_f << 1);
                12'd34: toneL = (`sh_f << 1);      12'd35: toneL = (`sh_f << 1);
                12'd36: toneL = (`sh_f << 1);      12'd37: toneL = (`sh_f << 1);
                12'd38: toneL = (`sh_f << 1);      12'd39: toneL = (`sh_f << 1);
                12'd40: toneL = (`sh_f << 1);      12'd41: toneL = (`sh_f << 1);
                12'd42: toneL = (`sh_f << 1);      12'd43: toneL = (`sh_f << 1);
                12'd44: toneL = (`sh_f << 1);      12'd45: toneL = (`sh_f << 1);
                12'd46: toneL = (`sh_f << 1);      12'd47: toneL = `sil;
                
                12'd48: toneL = (`sh_f << 1);      12'd49: toneL = (`sh_f << 1);
                12'd50: toneL = (`sh_f << 1);      12'd51: toneL = (`sh_f << 1);
                12'd52: toneL = (`sh_f << 1);      12'd53: toneL = (`sh_f << 1);
                12'd54: toneL = (`sh_g << 1);      12'd55: toneL = (`sh_g << 1);
                12'd56: toneL = (`sh_g << 1);      12'd57: toneL = (`sh_g << 1);
                12'd58: toneL = (`sh_g << 1);      12'd59: toneL = (`a << 1);
                12'd60: toneL = (`a << 1);         12'd61: toneL = (`a << 1);
                12'd62: toneL = (`a << 1);         12'd63: toneL = (`a << 1);
                
                12'd64: toneL = (`sh_g << 1);      12'd65: toneL = (`sh_g << 1);
                12'd66: toneL = (`sh_g << 1);      12'd67: toneL = (`sh_g << 1);
                12'd68: toneL = (`sh_g << 1);      12'd69: toneL = (`sh_g << 1);
                12'd70: toneL = (`sh_g << 1);      12'd71: toneL = (`sh_g << 1);
                12'd72: toneL = (`sh_g << 1);      12'd73: toneL = (`sh_g << 1);
                12'd74: toneL = (`sh_g << 1);      12'd75: toneL = (`sh_g << 1);
                12'd76: toneL = (`sh_g << 1);      12'd77: toneL = (`sh_g << 1);
                12'd78: toneL = (`sh_g << 1);      12'd79: toneL = (`sh_g << 1);
                
                12'd80: toneL = (`sh_c << 1);      12'd81: toneL = (`sh_c << 1);
                12'd82: toneL = (`sh_c << 1);      12'd83: toneL = (`sh_c << 1);
                12'd84: toneL = (`sh_c << 1);      12'd85: toneL = `sil;
                12'd86: toneL = (`sh_c << 1);      12'd87: toneL = (`sh_c << 1);
                12'd88: toneL = (`sh_c << 1);      12'd89: toneL = (`sh_c << 1);
                12'd90: toneL = `sil;              12'd91: toneL = (`sh_c << 1);
                12'd92: toneL = (`sh_c << 1);      12'd93: toneL = (`sh_c << 1);
                12'd94: toneL = (`sh_c << 1);      12'd95: toneL = (`sh_c << 1);      
                
                12'd96: toneL = (`sh_g << 1);      12'd97: toneL = (`sh_g << 1);
                12'd98: toneL = (`sh_g << 1);      12'd99: toneL = (`sh_g << 1);
                12'd100: toneL = (`sh_g << 1);     12'd101: toneL = (`sh_g << 1);
                12'd102: toneL = (`sh_g << 1);     12'd103: toneL = (`sh_g << 1);
                12'd104: toneL = (`sh_g << 1);     12'd105: toneL = (`sh_g << 1);
                12'd106: toneL = (`sh_g << 1);     12'd107: toneL = (`sh_g << 1);
                12'd108: toneL = (`sh_g << 1);     12'd109: toneL = (`sh_g << 1);
                12'd110: toneL = (`sh_g << 1);     12'd111: toneL = `sil;
                
                12'd112: toneL = (`sh_g << 1);     12'd113: toneL = (`sh_g << 1);
                12'd114: toneL = (`sh_g << 1);     12'd115: toneL = (`sh_g << 1);
                12'd116: toneL = (`sh_g << 1);     12'd117: toneL = (`sh_g << 1);
                12'd118: toneL = (`a << 1);        12'd119: toneL = (`a << 1);
                12'd120: toneL = (`a << 1);        12'd121: toneL = (`a << 1);
                12'd122: toneL = (`a << 1);        12'd123: toneL = (`b << 1);
                12'd124: toneL = (`b << 1);        12'd125: toneL = (`b << 1);
                12'd126: toneL = (`b << 1);        12'd127: toneL = (`b << 1);
                
                12'd128: toneL = (`a << 1);        12'd129: toneL = (`a << 1);
                12'd130: toneL = (`a << 1);        12'd131: toneL = (`a << 1);
                12'd132: toneL = (`a << 1);        12'd133: toneL = (`a << 1);
                12'd134: toneL = (`a << 1);        12'd135: toneL = (`a << 1);
                12'd136: toneL = (`a << 1);        12'd137: toneL = (`a << 1);
                12'd138: toneL = (`a << 1);        12'd139: toneL = (`a << 1);
                12'd140: toneL = (`a << 1);        12'd141: toneL = (`a << 1);
                12'd142: toneL = (`a << 1);        12'd143: toneL = (`a << 1);
                
                12'd144: toneL = (`sh_f << 1);     12'd145: toneL = (`sh_f << 1);
                12'd146: toneL = (`sh_f << 1);     12'd147: toneL = (`sh_f << 1);
                12'd148: toneL = (`sh_f << 1);     12'd149: toneL = `sil;
                12'd150: toneL = (`sh_f << 1);     12'd151: toneL = (`sh_f << 1);
                12'd152: toneL = (`sh_f << 1);     12'd153: toneL = (`sh_f << 1);
                12'd154: toneL = `sil;             12'd155: toneL = (`sh_f << 1);
                12'd156: toneL = (`sh_f << 1);     12'd157: toneL = (`sh_f << 1);
                12'd158: toneL = (`sh_f << 1);     12'd159: toneL = (`sh_f << 1);
                
                12'd160: toneL = (`a << 1);        12'd161: toneL = (`a << 1);
                12'd162: toneL = (`a << 1);        12'd163: toneL = (`a << 1);
                12'd164: toneL = (`a << 1);        12'd165: toneL = (`a << 1);
                12'd166: toneL = (`a << 1);        12'd167: toneL = (`a << 1);
                12'd168: toneL = (`a << 1);        12'd169: toneL = (`a << 1);
                12'd170: toneL = (`a << 1);        12'd171: toneL = (`a << 1);
                12'd172: toneL = (`a << 1);        12'd173: toneL = (`a << 1);
                12'd174: toneL = (`a << 1);        12'd175: toneL = (`a << 1);
                
                12'd176: toneL = (`sh_f << 1);     12'd177: toneL = (`sh_f << 1);
                12'd178: toneL = (`sh_f << 1);     12'd179: toneL = (`sh_f << 1);
                12'd180: toneL = (`sh_f << 1);     12'd181: toneL = (`sh_f << 1);
                12'd182: toneL = (`sh_g << 1);     12'd183: toneL = (`sh_g << 1);
                12'd184: toneL = (`sh_g << 1);     12'd185: toneL = (`sh_g << 1);
                12'd186: toneL = (`sh_g << 1);     12'd187: toneL = (`sh_f << 1);
                12'd188: toneL = (`sh_f << 1);     12'd189: toneL = (`sh_f << 1);
                12'd190: toneL = (`sh_f << 1);     12'd191: toneL = `sil;
                
                12'd192: toneL = (`sh_f << 1);     12'd193: toneL = (`sh_f << 1);
                12'd194: toneL = (`sh_f << 1);     12'd195: toneL = (`sh_f << 1);
                12'd196: toneL = (`sh_f << 1);     12'd197: toneL = (`sh_f << 1);
                12'd198: toneL = (`sh_f << 1);     12'd199: toneL = (`sh_f << 1);
                12'd200: toneL = (`sh_f << 1);     12'd201: toneL = (`sh_f << 1);
                12'd202: toneL = (`sh_f << 1);     12'd203: toneL = (`sh_f << 1);
                12'd204: toneL = (`sh_f << 1);     12'd205: toneL = (`sh_f << 1);
                12'd206: toneL = (`sh_f << 1);     12'd207: toneL = (`sh_f << 1);
                
                12'd208: toneL = `sil;             12'd209: toneL = `sil;
                12'd210: toneL = `sil;             12'd211: toneL = `sil;
                12'd212: toneL = `sil;             12'd213: toneL = `sil;
                12'd214: toneL = (`sh_g << 1);     12'd215: toneL = (`sh_g << 1);
                12'd216: toneL = (`sh_g << 1);     12'd217: toneL = (`sh_g << 1);
                12'd218: toneL = (`sh_g << 1);     12'd219: toneL = (`sh_f << 1);
                12'd220: toneL = (`sh_f << 1);     12'd221: toneL = (`sh_f << 1);
                12'd222: toneL = (`sh_f << 1);     12'd223: toneL = (`sh_f << 1);
                
                12'd224: toneL = (`sh_e << 1);     12'd225: toneL = (`sh_e << 1);
                12'd226: toneL = (`sh_e << 1);     12'd227: toneL = (`sh_e << 1);
                12'd228: toneL = (`sh_e << 1);     12'd229: toneL = (`sh_e << 1);
                12'd230: toneL = (`sh_e << 1);     12'd231: toneL = (`sh_e << 1);
                12'd232: toneL = (`sh_e << 1);     12'd233: toneL = (`sh_e << 1);
                12'd234: toneL = (`sh_e << 1);     12'd235: toneL = (`sh_e << 1);
                12'd236: toneL = (`sh_e << 1);     12'd237: toneL = (`sh_e << 1);
                12'd238: toneL = (`sh_e << 1);     12'd239: toneL = (`sh_e << 1);
                
                12'd240: toneL = (`sh_e << 1);     12'd241: toneL = (`sh_e << 1);
                12'd242: toneL = (`sh_e << 1);     12'd243: toneL = (`sh_e << 1);
                12'd244: toneL = (`sh_e << 1);     12'd245: toneL = (`sh_e << 1);     
                12'd246: toneL = (`sh_f << 1);     12'd247: toneL = (`sh_f << 1);
                12'd248: toneL = (`sh_f << 1);     12'd249: toneL = (`sh_f << 1);
                12'd250: toneL = (`sh_f << 1);     12'd251: toneL = (`sh_g << 1);
                12'd252: toneL = (`sh_g << 1);     12'd253: toneL = (`sh_g << 1);
                12'd254: toneL = (`sh_g << 1);     12'd255: toneL = (`sh_g << 1);
                
                12'd256: toneL = (`sh_f << 1);     12'd257: toneL = (`sh_f << 1);
                12'd258: toneL = (`sh_f << 1);     12'd259: toneL = (`sh_f << 1);
                12'd260: toneL = (`sh_f << 1);     12'd261: toneL = (`sh_f << 1);
                12'd262: toneL = (`sh_f << 1);     12'd263: toneL = (`sh_f << 1);
                12'd264: toneL = (`sh_f << 1);     12'd265: toneL = (`sh_f << 1);
                12'd266: toneL = (`sh_f << 1);     12'd267: toneL = (`sh_f << 1);
                12'd268: toneL = (`sh_f << 1);     12'd269: toneL = (`sh_f << 1);
                12'd270: toneL = (`sh_f << 1);     12'd271: toneL = (`sh_f << 1);
                
                12'd272: toneL = (`sh_c << 1);     12'd273: toneL = (`sh_c << 1);
                12'd274: toneL = (`sh_c << 1);     12'd275: toneL = (`sh_c << 1);
                12'd276: toneL = (`sh_c << 1);     12'd277: toneL = `sil;
                12'd278: toneL = (`sh_c << 1);     12'd279: toneL = (`sh_c << 1);
                12'd280: toneL = (`sh_c << 1);     12'd281: toneL = (`sh_c << 1);
                12'd282: toneL = `sil;             12'd283: toneL = (`sh_c << 1);
                12'd284: toneL = (`sh_c << 1);     12'd285: toneL = (`sh_c << 1);
                12'd286: toneL = (`sh_c << 1);     12'd287: toneL = (`sh_c << 1);
                
                12'd288: toneL = (`sh_f << 1);     12'd289: toneL = (`sh_f << 1);
                12'd290: toneL = (`sh_f << 1);     12'd291: toneL = (`sh_f << 1);
                12'd292: toneL = (`sh_f << 1);     12'd293: toneL = (`sh_f << 1);
                12'd294: toneL = (`sh_f << 1);     12'd295: toneL = (`sh_f << 1);
                12'd296: toneL = (`sh_f << 1);     12'd297: toneL = (`sh_f << 1);
                12'd298: toneL = (`sh_f << 1);     12'd299: toneL = (`sh_f << 1);
                12'd300: toneL = (`sh_f << 1);     12'd301: toneL = (`sh_f << 1);
                12'd302: toneL = (`sh_f << 1);     12'd303: toneL = `sil;
                
                12'd304: toneL = (`sh_f << 1);     12'd305: toneL = (`sh_f << 1);
                12'd306: toneL = (`sh_f << 1);     12'd307: toneL = (`sh_f << 1);
                12'd308: toneL = (`sh_f << 1);     12'd309: toneL = (`sh_f << 1);
                12'd310: toneL = (`sh_g << 1);     12'd311: toneL = (`sh_g << 1);
                12'd312: toneL = (`sh_g << 1);     12'd313: toneL = (`sh_g << 1);
                12'd314: toneL = (`sh_g << 1);     12'd315: toneL = (`a << 1);
                12'd316: toneL = (`a << 1);        12'd317: toneL = (`a << 1);
                12'd318: toneL = (`a << 1);        12'd319: toneL = (`a << 1);
                
                12'd320: toneL = (`sh_g << 1);     12'd321: toneL = (`sh_g << 1);
                12'd322: toneL = (`sh_g << 1);     12'd323: toneL = (`sh_g << 1);
                12'd324: toneL = (`sh_g << 1);     12'd325: toneL = (`sh_g << 1);
                12'd326: toneL = (`sh_g << 1);     12'd327: toneL = (`sh_g << 1);
                12'd328: toneL = (`sh_g << 1);     12'd329: toneL = (`sh_g << 1);
                12'd330: toneL = (`sh_g << 1);     12'd331: toneL = (`sh_g << 1);
                12'd332: toneL = (`sh_g << 1);     12'd333: toneL = (`sh_g << 1);
                12'd334: toneL = (`sh_g << 1);     12'd335: toneL = (`sh_g << 1);
                
                12'd336: toneL = (`sh_c << 1);     12'd337: toneL = (`sh_c << 1);
                12'd338: toneL = (`sh_c << 1);     12'd339: toneL = (`sh_c << 1);
                12'd340: toneL = (`sh_c << 1);     12'd341: toneL = `sil;
                12'd342: toneL = (`sh_c << 1);     12'd343: toneL = (`sh_c << 1);
                12'd344: toneL = (`sh_c << 1);     12'd345: toneL = (`sh_c << 1);
                12'd346: toneL = `sil;             12'd347: toneL = (`sh_c << 1);
                12'd348: toneL = (`sh_c << 1);     12'd349: toneL = (`sh_c << 1);
                12'd350: toneL = (`sh_c << 1);     12'd351: toneL = (`sh_c << 1);
                
                12'd352: toneL = (`sh_g << 1);     12'd353: toneL = (`sh_g << 1);
                12'd354: toneL = (`sh_g << 1);     12'd355: toneL = (`sh_g << 1);
                12'd356: toneL = (`sh_g << 1);     12'd357: toneL = (`sh_g << 1);
                12'd358: toneL = (`sh_g << 1);     12'd359: toneL = (`sh_g << 1);
                12'd360: toneL = (`sh_g << 1);     12'd361: toneL = (`sh_g << 1);
                12'd362: toneL = (`sh_g << 1);     12'd363: toneL = (`sh_g << 1);
                12'd364: toneL = (`sh_g << 1);     12'd365: toneL = (`sh_g << 1);
                12'd366: toneL = (`sh_g << 1);     12'd367: toneL = `sil;
                
                12'd368: toneL = (`sh_g << 1);     12'd369: toneL = (`sh_g << 1);
                12'd370: toneL = (`sh_g << 1);     12'd371: toneL = (`sh_g << 1);
                12'd372: toneL = (`sh_g << 1);     12'd373: toneL = (`sh_g << 1);
                12'd374: toneL = (`a << 1);        12'd375: toneL = (`a << 1);
                12'd376: toneL = (`a << 1);        12'd377: toneL = (`a << 1);
                12'd378: toneL = (`a << 1);        12'd379: toneL = (`b << 1);
                12'd380: toneL = (`b << 1);        12'd381: toneL = (`b << 1);
                12'd382: toneL = (`b << 1);        12'd383: toneL = (`b << 1);
                
                12'd384: toneL = (`a << 1);        12'd385: toneL = (`a << 1);
                12'd386: toneL = (`a << 1);        12'd387: toneL = (`a << 1);
                12'd388: toneL = (`a << 1);        12'd389: toneL = (`a << 1);
                12'd390: toneL = (`a << 1);        12'd391: toneL = (`a << 1);
                12'd392: toneL = (`a << 1);        12'd393: toneL = (`a << 1);
                12'd394: toneL = (`a << 1);        12'd395: toneL = (`a << 1);
                12'd396: toneL = (`a << 1);        12'd397: toneL = (`a << 1);
                12'd398: toneL = (`a << 1);        12'd399: toneL = (`a << 1);
                
                12'd400: toneL = (`sh_f << 1);     12'd401: toneL = (`sh_f << 1);
                12'd402: toneL = (`sh_f << 1);     12'd403: toneL = (`sh_f << 1);
                12'd404: toneL = (`sh_f << 1);     12'd405: toneL = `sil;
                12'd406: toneL = (`sh_f << 1);     12'd407: toneL = (`sh_f << 1);
                12'd408: toneL = (`sh_f << 1);     12'd409: toneL = (`sh_f << 1);
                12'd410: toneL = `sil;             12'd411: toneL = (`sh_f << 1);
                12'd412: toneL = (`sh_f << 1);     12'd413: toneL = (`sh_f << 1);
                12'd414: toneL = (`sh_f << 1);     12'd415: toneL = (`sh_f << 1);
                
                12'd416: toneL = (`a << 1);        12'd417: toneL = (`a << 1);
                12'd418: toneL = (`a << 1);        12'd419: toneL = (`a << 1);
                12'd420: toneL = (`a << 1);        12'd421: toneL = (`a << 1);
                12'd422: toneL = (`a << 1);        12'd423: toneL = (`a << 1);
                12'd424: toneL = (`a << 1);        12'd425: toneL = (`a << 1);
                12'd426: toneL = (`a << 1);        12'd427: toneL = (`a << 1);
                12'd428: toneL = (`a << 1);        12'd429: toneL = (`a << 1);
                12'd430: toneL = (`a << 1);        12'd431: toneL = `sil;
                
                12'd432: toneL = (`a << 1);        12'd433: toneL = (`a << 1);
                12'd434: toneL = (`a << 1);        12'd435: toneL = (`a << 1);
                12'd436: toneL = (`a << 1);        12'd437: toneL = (`a << 1);
                12'd438: toneL = (`b << 1);        12'd439: toneL = (`b << 1);
                12'd440: toneL = (`b << 1);        12'd441: toneL = (`b << 1);
                12'd442: toneL = (`b << 1);        12'd443: toneL = (`sh_hc << 1);
                12'd444: toneL = (`sh_hc << 1);    12'd445: toneL = (`sh_hc << 1);
                12'd446: toneL = (`sh_hc << 1);    12'd447: toneL = (`sh_hc << 1);
                
                12'd448: toneL = (`b << 1);        12'd449: toneL = (`b << 1);
                12'd450: toneL = (`b << 1);        12'd451: toneL = (`b << 1);
                12'd452: toneL = (`b << 1);        12'd453: toneL = (`b << 1);
                12'd454: toneL = (`b << 1);        12'd455: toneL = (`b << 1);
                12'd456: toneL = (`b << 1);        12'd457: toneL = (`b << 1);
                12'd458: toneL = (`b << 1);        12'd459: toneL = (`b << 1);
                12'd460: toneL = (`b << 1);        12'd461: toneL = (`b << 1);
                12'd462: toneL = (`b << 1);        12'd463: toneL = (`b << 1);
                
                12'd464: toneL = `sil;             12'd465: toneL = `sil;
                12'd466: toneL = `sil;             12'd467: toneL = `sil;
                12'd468: toneL = `sil;             12'd469: toneL = `sil;
                12'd470: toneL = (`sh_f << 1);     12'd471: toneL = (`sh_f << 1);
                12'd472: toneL = (`sh_f << 1);     12'd473: toneL = (`sh_f << 1);
                12'd474: toneL = `sil;             12'd475: toneL = (`sh_f << 1);
                12'd476: toneL = (`sh_f << 1);     12'd477: toneL = (`sh_f << 1);
                12'd478: toneL = (`sh_f << 1);     12'd479: toneL = `sil;
                
                12'd480: toneL = (`sh_f << 1);     12'd481: toneL = (`sh_f << 1);
                12'd482: toneL = (`sh_f << 1);     12'd483: toneL = (`sh_f << 1);
                12'd484: toneL = (`sh_f << 1);     12'd485: toneL = (`sh_f << 1);
                12'd486: toneL = (`sh_f << 1);     12'd487: toneL = (`sh_f << 1);
                12'd488: toneL = (`sh_f << 1);     12'd489: toneL = (`sh_f << 1);
                12'd490: toneL = (`sh_f << 1);     12'd491: toneL = (`sh_f << 1);
                12'd492: toneL = (`sh_f << 1);     12'd493: toneL = (`sh_f << 1);
                12'd494: toneL = (`sh_f << 1);     12'd495: toneL = (`sh_f << 1);
                
                12'd496: toneL = (`sh_f << 1);     12'd497: toneL = (`sh_f << 1);
                12'd498: toneL = (`sh_f << 1);     12'd499: toneL = (`sh_f << 1);
                12'd500: toneL = (`sh_f << 1);     12'd501: toneL = `sil;
                12'd502: toneL = (`sh_f << 1);     12'd503: toneL = (`sh_f << 1);
                12'd504: toneL = (`sh_f << 1);     12'd505: toneL = (`sh_f << 1);
                12'd506: toneL = (`sh_f << 1);     12'd507: toneL = (`sh_g << 1);
                12'd508: toneL = (`sh_g << 1);     12'd509: toneL = (`sh_g << 1);
                12'd510: toneL = (`sh_g << 1);     12'd511: toneL = (`sh_g << 1);
                
                12'd512: toneL = (`a << 1);        12'd513: toneL = (`a << 1);
                12'd514: toneL = (`a << 1);        12'd515: toneL = (`a << 1);
                12'd516: toneL = (`a << 1);        12'd517: toneL = (`a << 1);
                12'd518: toneL = (`a << 1);        12'd519: toneL = (`a << 1);
                12'd520: toneL = (`a << 1);        12'd521: toneL = (`a << 1);
                12'd522: toneL = (`a << 1);        12'd523: toneL = (`a << 1);
                12'd524: toneL = (`a << 1);        12'd525: toneL = (`a << 1);
                12'd526: toneL = (`a << 1);        12'd527: toneL = (`a << 1);
                
                12'd528: toneL = `sil;             12'd529: toneL = `sil;
                12'd530: toneL = `sil;             12'd531: toneL = `sil;
                12'd532: toneL = `sil;             12'd533: toneL = `sil;
                12'd534: toneL = (`sh_g << 1);     12'd535: toneL = (`sh_g << 1);
                12'd536: toneL = (`sh_g << 1);     12'd537: toneL = (`sh_g << 1);
                12'd538: toneL = (`sh_g << 1);     12'd539: toneL = (`a << 1);
                12'd540: toneL = (`a << 1);        12'd541: toneL = (`a << 1);
                12'd542: toneL = (`a << 1);        12'd543: toneL = (`a << 1);
                
                12'd544: toneL = (`b << 1);        12'd545: toneL = (`b << 1);
                12'd546: toneL = (`b << 1);        12'd547: toneL = (`b << 1);
                12'd548: toneL = (`b << 1);        12'd549: toneL = (`b << 1);
                12'd550: toneL = (`b << 1);        12'd551: toneL = (`b << 1);
                12'd552: toneL = (`b << 1);        12'd553: toneL = (`b << 1);        
                12'd554: toneL = (`a << 1);        12'd555: toneL = (`a << 1);
                12'd556: toneL = (`a << 1);        12'd557: toneL = (`a << 1);
                12'd558: toneL = (`a << 1);        12'd559: toneL = (`a << 1);
                
                12'd560: toneL = (`a << 1);        12'd561: toneL = (`a << 1);
                12'd562: toneL = (`a << 1);        12'd563: toneL = (`a << 1);
                12'd564: toneL = (`a << 1);        12'd565: toneL = (`sh_g << 1);
                12'd566: toneL = (`sh_g << 1);     12'd567: toneL = (`sh_g << 1);
                12'd568: toneL = (`sh_g << 1);     12'd569: toneL = (`sh_g << 1);
                12'd570: toneL = (`sh_g << 1);     12'd571: toneL = (`sh_g << 1);
                12'd572: toneL = (`sh_g << 1);     12'd573: toneL = (`sh_g << 1);
                12'd574: toneL = (`sh_g << 1);     12'd575: toneL = (`sh_g << 1);
                
                12'd576: toneL = (`a << 1);        12'd577: toneL = (`a << 1);
                12'd578: toneL = (`a << 1);        12'd579: toneL = (`a << 1);
                12'd580: toneL = (`a << 1);        12'd581: toneL = (`a << 1);
                12'd582: toneL = (`a << 1);        12'd583: toneL = (`a << 1);
                12'd584: toneL = (`a << 1);        12'd585: toneL = (`a << 1);
                12'd586: toneL = (`a << 1);        12'd587: toneL = (`a << 1);
                12'd588: toneL = (`a << 1);        12'd589: toneL = (`a << 1);
                12'd590: toneL = (`a << 1);        12'd591: toneL = (`a << 1);
                
                12'd592: toneL = `sil;             12'd593: toneL = `sil;
                12'd594: toneL = `sil;             12'd595: toneL = `sil;
                12'd596: toneL = `sil;             12'd597: toneL = `sil;
                12'd598: toneL = (`sh_g << 1);     12'd599: toneL = (`sh_g << 1);
                12'd600: toneL = (`sh_g << 1);     12'd601: toneL = (`sh_g << 1);
                12'd602: toneL = (`sh_g << 1);     12'd603: toneL = (`sh_f << 1);
                12'd604: toneL = (`sh_f << 1);     12'd605: toneL = (`sh_f << 1);
                12'd606: toneL = (`sh_f << 1);     12'd607: toneL = (`sh_f << 1);
                
                12'd608: toneL = (`sh_g << 1);     12'd609: toneL = (`sh_g << 1);
                12'd610: toneL = (`sh_g << 1);     12'd611: toneL = (`sh_g << 1);
                12'd612: toneL = (`sh_g << 1);     12'd613: toneL = (`sh_g << 1);
                12'd614: toneL = (`sh_g << 1);     12'd615: toneL = (`sh_g << 1);
                12'd616: toneL = (`sh_g << 1);     12'd617: toneL = (`sh_g << 1);
                12'd618: toneL = (`sh_g << 1);     12'd619: toneL = (`sh_g << 1);
                12'd620: toneL = (`sh_g << 1);     12'd621: toneL = (`sh_g << 1);
                12'd622: toneL = (`sh_g << 1);     12'd623: toneL = (`sh_g << 1);
                
                12'd624: toneL = `sil;             12'd625: toneL = `sil;
                12'd626: toneL = (`sh_f << 1);     12'd627: toneL = (`sh_f << 1);
                12'd628: toneL = (`sh_f << 1);     12'd629: toneL = (`sh_f << 1);
                12'd630: toneL = (`sh_f << 1);     12'd631: toneL = (`sh_f << 1);
                12'd632: toneL = (`sh_f << 1);     12'd633: toneL = (`sh_f << 1);
                12'd634: toneL = (`sh_g << 1);     12'd635: toneL = (`sh_g << 1);
                12'd636: toneL = (`sh_g << 1);     12'd637: toneL = (`sh_g << 1);
                12'd638: toneL = (`sh_g << 1);     12'd639: toneL = (`sh_g << 1);
                
                12'd640: toneL = (`sh_f << 1);     12'd641: toneL = (`sh_f << 1);
                12'd642: toneL = (`sh_f << 1);     12'd643: toneL = (`sh_f << 1);
                12'd644: toneL = (`sh_f << 1);     12'd645: toneL = (`sh_f << 1);
                12'd646: toneL = (`sh_f << 1);     12'd647: toneL = (`sh_f << 1);
                12'd648: toneL = (`sh_f << 1);     12'd649: toneL = (`sh_f << 1);
                12'd650: toneL = (`sh_f << 1);     12'd651: toneL = (`sh_f << 1);
                12'd652: toneL = (`sh_f << 1);     12'd653: toneL = (`sh_f << 1);
                12'd654: toneL = (`sh_f << 1);     12'd655: toneL = (`sh_f << 1);
                
                12'd656: toneL = (`sh_f << 1);     12'd657: toneL = (`sh_f << 1);
                12'd658: toneL = (`sh_f << 1);     12'd659: toneL = (`sh_f << 1);
                12'd660: toneL = (`sh_f << 1);     12'd661: toneL = (`sh_f << 1);
                12'd662: toneL = (`sh_f << 1);     12'd663: toneL = (`sh_f << 1);
                12'd664: toneL = (`sh_f << 1);     12'd665: toneL = (`sh_f << 1);
                12'd666: toneL = (`sh_f << 1);     12'd667: toneL = (`sh_f << 1);
                12'd668: toneL = (`sh_f << 1);     12'd669: toneL = (`sh_f << 1);
                12'd670: toneL = (`sh_f << 1);     12'd671: toneL = (`sh_f << 1);
                
                12'd672: toneL = (`sh_f << 1);     12'd673: toneL = (`sh_f << 1);
                12'd674: toneL = (`sh_f << 1);     12'd675: toneL = (`sh_f << 1);
                12'd676: toneL = (`sh_f << 1);     12'd677: toneL = (`sh_f << 1);
                12'd678: toneL = (`sh_f << 1);     12'd679: toneL = (`sh_f << 1);
                12'd680: toneL = (`sh_f << 1);     12'd681: toneL = (`sh_f << 1);
                12'd682: toneL = (`sh_f << 1);     12'd683: toneL = (`sh_f << 1);
                12'd684: toneL = (`sh_f << 1);     12'd685: toneL = (`sh_f << 1);
                12'd686: toneL = (`sh_f << 1);     12'd687: toneL = (`sh_f << 1);
                
                12'd688: toneL = (`sh_f << 1);     12'd689: toneL = (`sh_f << 1);
                12'd690: toneL = (`sh_f << 1);     12'd691: toneL = (`sh_f << 1);
                12'd692: toneL = (`sh_f << 1);     12'd693: toneL = (`sh_f << 1);
                12'd694: toneL = (`sh_g << 1);     12'd695: toneL = (`sh_g << 1);
                12'd696: toneL = (`sh_g << 1);     12'd697: toneL = (`sh_g << 1);
                12'd698: toneL = (`sh_g << 1);     12'd699: toneL = (`sh_f << 1);
                12'd700: toneL = (`sh_f << 1);     12'd701: toneL = (`sh_f << 1);
                12'd702: toneL = (`sh_f << 1);     12'd703: toneL = (`sh_f << 1);
                
                12'd704: toneL = (`sh_e << 1);     12'd705: toneL = (`sh_e << 1);
                12'd706: toneL = (`sh_e << 1);     12'd707: toneL = (`sh_e << 1);
                12'd708: toneL = (`sh_e << 1);     12'd709: toneL = (`sh_e << 1);
                12'd710: toneL = (`sh_e << 1);     12'd711: toneL = (`sh_e << 1);
                12'd712: toneL = (`sh_e << 1);     12'd713: toneL = (`sh_e << 1);
                12'd714: toneL = (`sh_e << 1);     12'd715: toneL = (`sh_e << 1);
                12'd716: toneL = (`sh_e << 1);     12'd717: toneL = (`sh_e << 1);
                12'd718: toneL = (`sh_e << 1);     12'd719: toneL = (`sh_e << 1);
                
                12'd720: toneL = (`sh_e << 1);     12'd721: toneL = (`sh_e << 1);
                12'd722: toneL = (`sh_e << 1);     12'd723: toneL = (`sh_e << 1);
                12'd724: toneL = (`sh_e << 1);     12'd725: toneL = (`sh_e << 1);
                12'd726: toneL = (`sh_e << 1);     12'd727: toneL = (`sh_e << 1);
                12'd728: toneL = (`sh_e << 1);     12'd729: toneL = (`sh_e << 1);
                12'd730: toneL = (`sh_e << 1);     12'd731: toneL = (`sh_e << 1);
                12'd732: toneL = (`sh_e << 1);     12'd733: toneL = (`sh_e << 1);
                12'd734: toneL = (`sh_e << 1);     12'd735: toneL = (`sh_e << 1);
                
                12'd736: toneL = (`sh_e << 1);     12'd737: toneL = (`sh_e << 1);
                12'd738: toneL = (`sh_e << 1);     12'd739: toneL = (`sh_e << 1);
                12'd740: toneL = (`sh_e << 1);     12'd741: toneL = (`sh_e << 1);
                12'd742: toneL = (`sh_e << 1);     12'd743: toneL = (`sh_e << 1);
                12'd744: toneL = (`sh_e << 1);     12'd745: toneL = (`sh_e << 1);
                12'd746: toneL = (`sh_e << 1);     12'd747: toneL = (`sh_e << 1);
                12'd748: toneL = (`sh_e << 1);     12'd749: toneL = (`sh_e << 1);
                12'd750: toneL = (`sh_e << 1);     12'd751: toneL = (`sh_e << 1);
                
                12'd752: toneL = (`sh_e << 1);     12'd753: toneL = (`sh_e << 1);
                12'd754: toneL = (`sh_e << 1);     12'd755: toneL = (`sh_e << 1);
                12'd756: toneL = (`sh_e << 1);     12'd757: toneL = (`sh_e << 1);
                12'd758: toneL = (`sh_e << 1);     12'd759: toneL = (`sh_e << 1);
                12'd760: toneL = `sil;             12'd761: toneL = `sil;
                12'd762: toneL = `sil;             12'd763: toneL = `sil;
                12'd764: toneL = `sil;             12'd765: toneL = `sil;
                12'd766: toneL = `sil;             12'd767: toneL = `sil;
                
                default: toneL = `sil;
            endcase
        end
        else begin
            toneL = `sil;
        end
    end
endmodule