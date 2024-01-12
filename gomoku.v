module gomoku(
	output reg[7:0]data_r,data_g,data_b,
	output reg[3:0]comm,
	output reg red_win1,blue_win1,//贏家亮燈輸出
	output [0:6]seg, 
	output seg7_com1,seg7_com2,
	input clk,reset,up,down,left,right,enter

);

	divfreq F0(clk, clk_div);
	divfreq2 F2(clk, clk_div2);
	divfreq3 F3(clk, clk_div3);
	bit [2:0] cnt;
	reg [2:0] row;
	reg [2:0] column;
	reg [2:0] row0;
	reg [2:0] column0;
	bit flag_r;
	wire red_win;
	wire blue_win;
	wire [95:0] five_red;
	wire [95:0] five_blue;
	bit win;
	assign win=red_win1||blue_win1;
	reg timeout;
	
initial
	begin 
		cnt=0;
		data_r=8'b11111111;
		data_g=8'b11111111;
		data_b=8'b11111111;
		comm=4'b1000;
		row=0;
		column=0;
		flag_r=1;
		red_player='{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
		};
		blue_player='{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
		};
		cursor_g='{
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111,
		8'b11111111
		};
		
	end
	
	//儲存顯示用矩陣
	reg [0:7] red_player [0:7];
	reg [0:7] blue_player [0:7];
	reg [0:7] cursor_g [0:7];

always @(posedge clk_div)
	begin
		if(cnt>=7)
			cnt=0;
		else 
			cnt = cnt+1;
			comm={1'b1,cnt};
			data_r=red_player[cnt];
			data_b=blue_player[cnt];
			data_g=cursor_g[cnt];
	
	if (a_count>=15 && enter==0 && flag_r==1)//如果超過時間對方贏
			blue_win1=1;
		else
			red_win1=red_win;
			blue_win1=blue_win;
		if (a_count>=15 && enter==0 && flag_r==0)
			red_win1=1;
		else
			red_win1=red_win;
			blue_win1=blue_win;
		if(reset)//清零
			red_win1<=0;
			blue_win1<=0;
			
	end
	
always @(posedge clk_div2)//上下左右
	begin
		if(reset)//清零
			begin
				for(int i=0;i<8;i++)
					begin
						for(int j=0;j<8;j++)
							begin
								cursor_g[i][j]<=1;
							end
					end
				row=0;
				column=0;
				row0=0;
				column0=0;
			end
		else
		begin
			if (up)
				begin
					if(column>=7)
						begin
							cursor_g[row][7]<=1;//原本的位置暗燈
							cursor_g[row][0]<=0;//要前進的位置亮燈
							column=0;
						end
					else
						begin
							cursor_g[row][column]<=1;
							cursor_g[row][column+1]<=0;
							column=column+1;
						end
				end
			
			else if (down)
				begin
					if(column==0)
						begin
							cursor_g[row][0]<=1;
							cursor_g[row][7]<=0;
							column=7;
						end
					else
						begin
							cursor_g[row][column]<=1;
							cursor_g[row][column-1]<=0;
							column=column-1;
						end
				end
			else if (left)
				begin
					if(row==0)
						begin
							cursor_g[0][column]<=1;
							cursor_g[7][column]<=0;
							row=7;
						end
					else
						begin
							cursor_g[row][column]<=1;
							cursor_g[row-1][column]<=0;
							row=row-1;
						end
				end
			else if (right)
				begin
					if(row==7)
						begin
							cursor_g[7][column]<=1;
							cursor_g[0][column]<=0;
							row=0;
						end
					else
						begin
							cursor_g[row][column]<=1;
							cursor_g[row+1][column]<=0;
							row=row+1;
						end
				end
		end		
			
	end
			
	
always @(posedge clk_div3)//下棋
	begin
		if(reset)//清零
			begin
				for(int i=0;i<8;i++)
					begin
						for(int j=0;j<8;j++)
							begin
								red_player[i][j]<=1;
								blue_player[i][j]<=1;
								flag_r<=1;
								
							end
					end
			end
		else if(enter==1 && flag_r==1 &&red_player[row][column]==1&&blue_player[row][column]==1)//可下棋的條件
			begin
				red_player[row][column]<=0;
				flag_r=~flag_r;
			end
		else if(enter==1 && flag_r==0 &&red_player[row][column]==1&&blue_player[row][column]==1)
			begin
				blue_player[row][column]<=0;
				flag_r=~flag_r;
				
			end
		
	
	end
	
 //窮舉法規則
assign five_red[0] = ~red_player[0][0]&&~red_player[1][0]&&~red_player[2][0]&&~red_player[3][0]&&~red_player[4][0];
assign five_red[1] = ~red_player[1][0]&&~red_player[2][0]&&~red_player[3][0]&&~red_player[4][0]&&~red_player[5][0];
assign five_red[2] = ~red_player[2][0]&&~red_player[3][0]&&~red_player[4][0]&&~red_player[5][0]&&~red_player[6][0];
assign five_red[3] = ~red_player[3][0]&&~red_player[4][0]&&~red_player[5][0]&&~red_player[6][0]&&~red_player[7][0];
		 
assign five_red[4] = ~red_player[0][1]&&~red_player[1][1]&&~red_player[2][1]&&~red_player[3][1]&&~red_player[4][1];
assign five_red[5] = ~red_player[1][1]&&~red_player[2][1]&&~red_player[3][1]&&~red_player[4][1]&&~red_player[5][1];
assign five_red[6] = ~red_player[2][1]&&~red_player[3][1]&&~red_player[4][1]&&~red_player[5][1]&&~red_player[6][1];
assign five_red[7] = ~red_player[3][1]&&~red_player[4][1]&&~red_player[5][1]&&~red_player[6][1]&&~red_player[7][1]; 

assign five_red[8] = ~red_player[0][2]&&~red_player[1][2]&&~red_player[2][2]&&~red_player[3][2]&&~red_player[4][2];
assign five_red[9] = ~red_player[1][2]&&~red_player[2][2]&&~red_player[3][2]&&~red_player[4][2]&&~red_player[5][2];
assign five_red[10] = ~red_player[2][2]&&~red_player[3][2]&&~red_player[4][2]&&~red_player[5][2]&&~red_player[6][2];
assign five_red[11] = ~red_player[3][2]&&~red_player[4][2]&&~red_player[5][2]&&~red_player[6][2]&&~red_player[7][2];
		 
assign five_red[12] = ~red_player[0][3]&&~red_player[1][3]&&~red_player[2][3]&&~red_player[3][3]&&~red_player[4][3];
assign five_red[13] = ~red_player[1][3]&&~red_player[2][3]&&~red_player[3][3]&&~red_player[4][3]&&~red_player[5][3];
assign five_red[14] = ~red_player[2][3]&&~red_player[3][3]&&~red_player[4][3]&&~red_player[5][3]&&~red_player[6][3];
assign five_red[15] = ~red_player[3][3]&&~red_player[4][3]&&~red_player[5][3]&&~red_player[6][3]&&~red_player[7][3];
		  
assign five_red[16] = ~red_player[0][4]&&~red_player[1][4]&&~red_player[2][4]&&~red_player[3][4]&&~red_player[4][4];
assign five_red[17] = ~red_player[1][4]&&~red_player[2][4]&&~red_player[3][4]&&~red_player[4][4]&&~red_player[5][4];
assign five_red[18] = ~red_player[2][4]&&~red_player[3][4]&&~red_player[4][4]&&~red_player[5][4]&&~red_player[6][4];
assign five_red[19] = ~red_player[3][4]&&~red_player[4][4]&&~red_player[5][4]&&~red_player[6][4]&&~red_player[7][4];
		 
assign five_red[20] = ~red_player[0][5]&&~red_player[1][5]&&~red_player[2][5]&&~red_player[3][5]&&~red_player[4][5];
assign five_red[21] = ~red_player[1][5]&&~red_player[2][5]&&~red_player[3][5]&&~red_player[4][5]&&~red_player[5][5];
assign five_red[22] = ~red_player[2][5]&&~red_player[3][5]&&~red_player[4][5]&&~red_player[5][5]&&~red_player[6][5];
assign five_red[23] = ~red_player[3][5]&&~red_player[4][5]&&~red_player[5][5]&&~red_player[6][5]&&~red_player[7][5];
		 
assign five_red[24] = ~red_player[0][6]&&~red_player[1][6]&&~red_player[2][6]&&~red_player[3][6]&&~red_player[4][6];
assign five_red[25] = ~red_player[1][6]&&~red_player[2][6]&&~red_player[3][6]&&~red_player[4][6]&&~red_player[5][6];
assign five_red[26] = ~red_player[2][6]&&~red_player[3][6]&&~red_player[4][6]&&~red_player[5][6]&&~red_player[6][6];
assign five_red[27] = ~red_player[3][6]&&~red_player[4][6]&&~red_player[5][6]&&~red_player[6][6]&&~red_player[7][6]; 
		 
assign five_red[28] = ~red_player[0][7]&&~red_player[1][7]&&~red_player[2][7]&&~red_player[3][7]&&~red_player[4][7];
assign five_red[29] = ~red_player[1][7]&&~red_player[2][7]&&~red_player[3][7]&&~red_player[4][7]&&~red_player[5][7];
assign five_red[30] = ~red_player[2][7]&&~red_player[3][7]&&~red_player[4][7]&&~red_player[5][7]&&~red_player[6][7];
assign five_red[31] = ~red_player[3][7]&&~red_player[4][7]&&~red_player[5][7]&&~red_player[6][7]&&~red_player[7][7];
		 //直
assign five_red[32] = ~red_player[0][0]&&~red_player[0][1]&&~red_player[0][2]&&~red_player[0][3]&&~red_player[0][4];
assign five_red[33] = ~red_player[0][1]&&~red_player[0][2]&&~red_player[0][3]&&~red_player[0][4]&&~red_player[0][5];
assign five_red[34] = ~red_player[0][2]&&~red_player[0][3]&&~red_player[0][4]&&~red_player[0][5]&&~red_player[0][6];
assign five_red[35] = ~red_player[0][3]&&~red_player[0][4]&&~red_player[0][5]&&~red_player[0][6]&&~red_player[0][7];
	
assign five_red[36] = ~red_player[1][0]&&~red_player[1][1]&&~red_player[1][2]&&~red_player[1][3]&&~red_player[1][4];
assign five_red[37] = ~red_player[1][1]&&~red_player[1][2]&&~red_player[1][3]&&~red_player[1][4]&&~red_player[1][5];
assign five_red[38] = ~red_player[1][2]&&~red_player[1][3]&&~red_player[1][4]&&~red_player[1][5]&&~red_player[1][6];
assign five_red[39] = ~red_player[1][3]&&~red_player[1][4]&&~red_player[1][5]&&~red_player[1][6]&&~red_player[1][7]; 

assign five_red[40] = ~red_player[2][0]&&~red_player[2][1]&&~red_player[2][2]&&~red_player[2][3]&&~red_player[2][4];
assign five_red[41] = ~red_player[2][1]&&~red_player[2][2]&&~red_player[2][3]&&~red_player[2][4]&&~red_player[2][5];
assign five_red[42] = ~red_player[2][2]&&~red_player[2][3]&&~red_player[2][4]&&~red_player[2][5]&&~red_player[2][6];
assign five_red[43] = ~red_player[2][3]&&~red_player[2][4]&&~red_player[2][5]&&~red_player[2][6]&&~red_player[2][7];
		 
assign five_red[44] = ~red_player[3][0]&&~red_player[3][1]&&~red_player[3][2]&&~red_player[3][3]&&~red_player[3][4];
assign five_red[45] = ~red_player[3][1]&&~red_player[3][2]&&~red_player[3][3]&&~red_player[3][4]&&~red_player[3][5];
assign five_red[46] = ~red_player[3][2]&&~red_player[3][3]&&~red_player[3][4]&&~red_player[3][5]&&~red_player[3][6];
assign five_red[47] = ~red_player[3][3]&&~red_player[3][4]&&~red_player[3][5]&&~red_player[3][6]&&~red_player[3][7];
		  
assign five_red[48] = ~red_player[4][0]&&~red_player[4][1]&&~red_player[4][2]&&~red_player[4][3]&&~red_player[4][4];
assign five_red[49] = ~red_player[4][1]&&~red_player[4][2]&&~red_player[4][3]&&~red_player[4][4]&&~red_player[4][5];
assign five_red[50] = ~red_player[4][2]&&~red_player[4][3]&&~red_player[4][4]&&~red_player[4][5]&&~red_player[4][6];
assign five_red[51] = ~red_player[4][3]&&~red_player[4][4]&&~red_player[4][5]&&~red_player[4][6]&&~red_player[4][7];
		 
assign five_red[52] = ~red_player[5][0]&&~red_player[5][1]&&~red_player[5][2]&&~red_player[5][3]&&~red_player[5][4];
assign five_red[53] = ~red_player[5][1]&&~red_player[5][2]&&~red_player[5][3]&&~red_player[5][4]&&~red_player[5][5];
assign five_red[54] = ~red_player[5][2]&&~red_player[5][3]&&~red_player[5][4]&&~red_player[5][5]&&~red_player[5][6];
assign five_red[55] = ~red_player[5][3]&&~red_player[5][4]&&~red_player[5][5]&&~red_player[5][6]&&~red_player[5][7];
		 
assign five_red[56] = ~red_player[6][0]&&~red_player[6][1]&&~red_player[6][2]&&~red_player[6][3]&&~red_player[6][4];
assign five_red[57] = ~red_player[6][1]&&~red_player[6][2]&&~red_player[6][3]&&~red_player[6][4]&&~red_player[6][5];
assign five_red[58] = ~red_player[6][2]&&~red_player[6][3]&&~red_player[6][4]&&~red_player[6][5]&&~red_player[6][6];
assign five_red[59] = ~red_player[6][3]&&~red_player[6][4]&&~red_player[6][5]&&~red_player[6][6]&&~red_player[6][7]; 
		 
assign five_red[60] = ~red_player[7][0]&&~red_player[7][1]&&~red_player[7][2]&&~red_player[7][3]&&~red_player[7][4];
assign five_red[61] = ~red_player[7][1]&&~red_player[7][2]&&~red_player[7][3]&&~red_player[7][4]&&~red_player[7][5];
assign five_red[62] = ~red_player[7][2]&&~red_player[7][3]&&~red_player[7][4]&&~red_player[7][5]&&~red_player[7][6];
assign five_red[63] = ~red_player[7][3]&&~red_player[7][4]&&~red_player[7][5]&&~red_player[7][6]&&~red_player[7][7];
//橫
assign five_red[64] = ~red_player[0][0]&&~red_player[1][1]&&~red_player[2][2]&&~red_player[3][3]&&~red_player[4][4];
assign five_red[65] = ~red_player[1][1]&&~red_player[2][2]&&~red_player[3][3]&&~red_player[4][4]&&~red_player[5][5];
assign five_red[66] = ~red_player[2][2]&&~red_player[3][3]&&~red_player[4][4]&&~red_player[5][5]&&~red_player[6][6];
assign five_red[67] = ~red_player[3][3]&&~red_player[4][4]&&~red_player[5][5]&&~red_player[6][6]&&~red_player[7][7];
	
assign five_red[68] = ~red_player[1][0]&&~red_player[2][1]&&~red_player[3][2]&&~red_player[4][3]&&~red_player[5][4];
assign five_red[69] = ~red_player[2][1]&&~red_player[3][2]&&~red_player[4][3]&&~red_player[5][4]&&~red_player[6][5];
assign five_red[70] = ~red_player[3][2]&&~red_player[4][3]&&~red_player[5][4]&&~red_player[6][5]&&~red_player[7][6];

assign five_red[71] = ~red_player[2][0]&&~red_player[3][1]&&~red_player[4][2]&&~red_player[5][3]&&~red_player[6][4];
assign five_red[72] = ~red_player[3][1]&&~red_player[4][2]&&~red_player[5][3]&&~red_player[6][4]&&~red_player[7][5];

assign five_red[73] = ~red_player[3][0]&&~red_player[4][1]&&~red_player[5][2]&&~red_player[6][3]&&~red_player[7][4];

assign five_red[74] = ~red_player[0][1]&&~red_player[1][2]&&~red_player[2][3]&&~red_player[3][4]&&~red_player[4][5];
assign five_red[75] = ~red_player[1][2]&&~red_player[2][3]&&~red_player[3][4]&&~red_player[4][5]&&~red_player[5][6];		 
assign five_red[76] = ~red_player[2][3]&&~red_player[3][4]&&~red_player[4][5]&&~red_player[5][6]&&~red_player[6][7];

assign five_red[77] = ~red_player[0][2]&&~red_player[1][3]&&~red_player[2][4]&&~red_player[3][5]&&~red_player[4][6];
assign five_red[78] = ~red_player[1][3]&&~red_player[2][4]&&~red_player[3][5]&&~red_player[4][6]&&~red_player[5][7];

assign five_red[79] = ~red_player[0][3]&&~red_player[1][4]&&~red_player[2][5]&&~red_player[3][6]&&~red_player[4][7];
//l斜  
assign five_red[80] = ~red_player[0][7]&&~red_player[1][6]&&~red_player[2][5]&&~red_player[3][4]&&~red_player[4][3];
assign five_red[81] = ~red_player[1][6]&&~red_player[2][5]&&~red_player[3][4]&&~red_player[4][3]&&~red_player[5][2];
assign five_red[82] = ~red_player[2][5]&&~red_player[3][4]&&~red_player[4][3]&&~red_player[5][2]&&~red_player[6][1];
assign five_red[83] = ~red_player[3][4]&&~red_player[4][3]&&~red_player[5][2]&&~red_player[6][1]&&~red_player[7][0];
		 
assign five_red[84] = ~red_player[1][7]&&~red_player[2][6]&&~red_player[3][5]&&~red_player[4][4]&&~red_player[5][3];
assign five_red[85] = ~red_player[2][6]&&~red_player[3][5]&&~red_player[4][4]&&~red_player[5][3]&&~red_player[6][2];
assign five_red[86] = ~red_player[3][5]&&~red_player[4][4]&&~red_player[5][3]&&~red_player[6][2]&&~red_player[7][1];

assign five_red[87] = ~red_player[2][7]&&~red_player[3][6]&&~red_player[4][5]&&~red_player[5][4]&&~red_player[6][3];
assign five_red[88] = ~red_player[3][6]&&~red_player[4][5]&&~red_player[5][4]&&~red_player[6][3]&&~red_player[7][2];

assign five_red[89] = ~red_player[3][7]&&~red_player[4][6]&&~red_player[5][5]&&~red_player[6][4]&&~red_player[7][3];

assign five_red[90] = ~red_player[0][6]&&~red_player[1][5]&&~red_player[2][4]&&~red_player[3][3]&&~red_player[4][2];
assign five_red[91] = ~red_player[1][5]&&~red_player[2][4]&&~red_player[3][3]&&~red_player[4][2]&&~red_player[5][1]; 
assign five_red[92] = ~red_player[2][4]&&~red_player[3][3]&&~red_player[4][2]&&~red_player[5][1]&&~red_player[6][0];

assign five_red[93] = ~red_player[0][5]&&~red_player[1][4]&&~red_player[2][3]&&~red_player[3][2]&&~red_player[4][1];
assign five_red[94] = ~red_player[1][4]&&~red_player[2][3]&&~red_player[3][2]&&~red_player[4][1]&&~red_player[5][0];

assign five_red[95] = ~red_player[0][4]&&~red_player[1][3]&&~red_player[2][2]&&~red_player[3][1]&&~red_player[4][0];//r斜

		 
assign red_win = |five_red;
///////////////////////////////////////////////////////////////////

assign five_blue[0] = ~blue_player[0][0]&&~blue_player[1][0]&&~blue_player[2][0]&&~blue_player[3][0]&&~blue_player[4][0];
assign five_blue[1] = ~blue_player[1][0]&&~blue_player[2][0]&&~blue_player[3][0]&&~blue_player[4][0]&&~blue_player[5][0];
assign five_blue[2] = ~blue_player[2][0]&&~blue_player[3][0]&&~blue_player[4][0]&&~blue_player[5][0]&&~blue_player[6][0];
assign five_blue[3] = ~blue_player[3][0]&&~blue_player[4][0]&&~blue_player[5][0]&&~blue_player[6][0]&&~blue_player[7][0];
		 
assign five_blue[4] = ~blue_player[0][1]&&~blue_player[1][1]&&~blue_player[2][1]&&~blue_player[3][1]&&~blue_player[4][1];
assign five_blue[5] = ~blue_player[1][1]&&~blue_player[2][1]&&~blue_player[3][1]&&~blue_player[4][1]&&~blue_player[5][1];
assign five_blue[6] = ~blue_player[2][1]&&~blue_player[3][1]&&~blue_player[4][1]&&~blue_player[5][1]&&~blue_player[6][1];
assign five_blue[7] = ~blue_player[3][1]&&~blue_player[4][1]&&~blue_player[5][1]&&~blue_player[6][1]&&~blue_player[7][1]; 

assign five_blue[8] = ~blue_player[0][2]&&~blue_player[1][2]&&~blue_player[2][2]&&~blue_player[3][2]&&~blue_player[4][2];
assign five_blue[9] = ~blue_player[1][2]&&~blue_player[2][2]&&~blue_player[3][2]&&~blue_player[4][2]&&~blue_player[5][2];
assign five_blue[10] = ~blue_player[2][2]&&~blue_player[3][2]&&~blue_player[4][2]&&~blue_player[5][2]&&~blue_player[6][2];
assign five_blue[11] = ~blue_player[3][2]&&~blue_player[4][2]&&~blue_player[5][2]&&~blue_player[6][2]&&~blue_player[7][2];
		 
assign five_blue[12] = ~blue_player[0][3]&&~blue_player[1][3]&&~blue_player[2][3]&&~blue_player[3][3]&&~blue_player[4][3];
assign five_blue[13] = ~blue_player[1][3]&&~blue_player[2][3]&&~blue_player[3][3]&&~blue_player[4][3]&&~blue_player[5][3];
assign five_blue[14] = ~blue_player[2][3]&&~blue_player[3][3]&&~blue_player[4][3]&&~blue_player[5][3]&&~blue_player[6][3];
assign five_blue[15] = ~blue_player[3][3]&&~blue_player[4][3]&&~blue_player[5][3]&&~blue_player[6][3]&&~blue_player[7][3];
		  
assign five_blue[16] = ~blue_player[0][4]&&~blue_player[1][4]&&~blue_player[2][4]&&~blue_player[3][4]&&~blue_player[4][4];
assign five_blue[17] = ~blue_player[1][4]&&~blue_player[2][4]&&~blue_player[3][4]&&~blue_player[4][4]&&~blue_player[5][4];
assign five_blue[18] = ~blue_player[2][4]&&~blue_player[3][4]&&~blue_player[4][4]&&~blue_player[5][4]&&~blue_player[6][4];
assign five_blue[19] = ~blue_player[3][4]&&~blue_player[4][4]&&~blue_player[5][4]&&~blue_player[6][4]&&~blue_player[7][4];
		 
assign five_blue[20] = ~blue_player[0][5]&&~blue_player[1][5]&&~blue_player[2][5]&&~blue_player[3][5]&&~blue_player[4][5];
assign five_blue[21] = ~blue_player[1][5]&&~blue_player[2][5]&&~blue_player[3][5]&&~blue_player[4][5]&&~blue_player[5][5];
assign five_blue[22] = ~blue_player[2][5]&&~blue_player[3][5]&&~blue_player[4][5]&&~blue_player[5][5]&&~blue_player[6][5];
assign five_blue[23] = ~blue_player[3][5]&&~blue_player[4][5]&&~blue_player[5][5]&&~blue_player[6][5]&&~blue_player[7][5];
		 
assign five_blue[24] = ~blue_player[0][6]&&~blue_player[1][6]&&~blue_player[2][6]&&~blue_player[3][6]&&~blue_player[4][6];
assign five_blue[25] = ~blue_player[1][6]&&~blue_player[2][6]&&~blue_player[3][6]&&~blue_player[4][6]&&~blue_player[5][6];
assign five_blue[26] = ~blue_player[2][6]&&~blue_player[3][6]&&~blue_player[4][6]&&~blue_player[5][6]&&~blue_player[6][6];
assign five_blue[27] = ~blue_player[3][6]&&~blue_player[4][6]&&~blue_player[5][6]&&~blue_player[6][6]&&~blue_player[7][6]; 
		 
assign five_blue[28] = ~blue_player[0][7]&&~blue_player[1][7]&&~blue_player[2][7]&&~blue_player[3][7]&&~blue_player[4][7];
assign five_blue[29] = ~blue_player[1][7]&&~blue_player[2][7]&&~blue_player[3][7]&&~blue_player[4][7]&&~blue_player[5][7];
assign five_blue[30] = ~blue_player[2][7]&&~blue_player[3][7]&&~blue_player[4][7]&&~blue_player[5][7]&&~blue_player[6][7];
assign five_blue[31] = ~blue_player[3][7]&&~blue_player[4][7]&&~blue_player[5][7]&&~blue_player[6][7]&&~blue_player[7][7];
		 //直
assign five_blue[32] = ~blue_player[0][0]&&~blue_player[0][1]&&~blue_player[0][2]&&~blue_player[0][3]&&~blue_player[0][4];
assign five_blue[33] = ~blue_player[0][1]&&~blue_player[0][2]&&~blue_player[0][3]&&~blue_player[0][4]&&~blue_player[0][5];
assign five_blue[34] = ~blue_player[0][2]&&~blue_player[0][3]&&~blue_player[0][4]&&~blue_player[0][5]&&~blue_player[0][6];
assign five_blue[35] = ~blue_player[0][3]&&~blue_player[0][4]&&~blue_player[0][5]&&~blue_player[0][6]&&~blue_player[0][7];
	
assign five_blue[36] = ~blue_player[1][0]&&~blue_player[1][1]&&~blue_player[1][2]&&~blue_player[1][3]&&~blue_player[1][4];
assign five_blue[37] = ~blue_player[1][1]&&~blue_player[1][2]&&~blue_player[1][3]&&~blue_player[1][4]&&~blue_player[1][5];
assign five_blue[38] = ~blue_player[1][2]&&~blue_player[1][3]&&~blue_player[1][4]&&~blue_player[1][5]&&~blue_player[1][6];
assign five_blue[39] = ~blue_player[1][3]&&~blue_player[1][4]&&~blue_player[1][5]&&~blue_player[1][6]&&~blue_player[1][7]; 

assign five_blue[40] = ~blue_player[2][0]&&~blue_player[2][1]&&~blue_player[2][2]&&~blue_player[2][3]&&~blue_player[2][4];
assign five_blue[41] = ~blue_player[2][1]&&~blue_player[2][2]&&~blue_player[2][3]&&~blue_player[2][4]&&~blue_player[2][5];
assign five_blue[42] = ~blue_player[2][2]&&~blue_player[2][3]&&~blue_player[2][4]&&~blue_player[2][5]&&~blue_player[2][6];
assign five_blue[43] = ~blue_player[2][3]&&~blue_player[2][4]&&~blue_player[2][5]&&~blue_player[2][6]&&~blue_player[2][7];
		 
assign five_blue[44] = ~blue_player[3][0]&&~blue_player[3][1]&&~blue_player[3][2]&&~blue_player[3][3]&&~blue_player[3][4];
assign five_blue[45] = ~blue_player[3][1]&&~blue_player[3][2]&&~blue_player[3][3]&&~blue_player[3][4]&&~blue_player[3][5];
assign five_blue[46] = ~blue_player[3][2]&&~blue_player[3][3]&&~blue_player[3][4]&&~blue_player[3][5]&&~blue_player[3][6];
assign five_blue[47] = ~blue_player[3][3]&&~blue_player[3][4]&&~blue_player[3][5]&&~blue_player[3][6]&&~blue_player[3][7];
		  
assign five_blue[48] = ~blue_player[4][0]&&~blue_player[4][1]&&~blue_player[4][2]&&~blue_player[4][3]&&~blue_player[4][4];
assign five_blue[49] = ~blue_player[4][1]&&~blue_player[4][2]&&~blue_player[4][3]&&~blue_player[4][4]&&~blue_player[4][5];
assign five_blue[50] = ~blue_player[4][2]&&~blue_player[4][3]&&~blue_player[4][4]&&~blue_player[4][5]&&~blue_player[4][6];
assign five_blue[51] = ~blue_player[4][3]&&~blue_player[4][4]&&~blue_player[4][5]&&~blue_player[4][6]&&~blue_player[4][7];
		 
assign five_blue[52] = ~blue_player[5][0]&&~blue_player[5][1]&&~blue_player[5][2]&&~blue_player[5][3]&&~blue_player[5][4];
assign five_blue[53] = ~blue_player[5][1]&&~blue_player[5][2]&&~blue_player[5][3]&&~blue_player[5][4]&&~blue_player[5][5];
assign five_blue[54] = ~blue_player[5][2]&&~blue_player[5][3]&&~blue_player[5][4]&&~blue_player[5][5]&&~blue_player[5][6];
assign five_blue[55] = ~blue_player[5][3]&&~blue_player[5][4]&&~blue_player[5][5]&&~blue_player[5][6]&&~blue_player[5][7];
		 
assign five_blue[56] = ~blue_player[6][0]&&~blue_player[6][1]&&~blue_player[6][2]&&~blue_player[6][3]&&~blue_player[6][4];
assign five_blue[57] = ~blue_player[6][1]&&~blue_player[6][2]&&~blue_player[6][3]&&~blue_player[6][4]&&~blue_player[6][5];
assign five_blue[58] = ~blue_player[6][2]&&~blue_player[6][3]&&~blue_player[6][4]&&~blue_player[6][5]&&~blue_player[6][6];
assign five_blue[59] = ~blue_player[6][3]&&~blue_player[6][4]&&~blue_player[6][5]&&~blue_player[6][6]&&~blue_player[6][7]; 
		 
assign five_blue[60] = ~blue_player[7][0]&&~blue_player[7][1]&&~blue_player[7][2]&&~blue_player[7][3]&&~blue_player[7][4];
assign five_blue[61] = ~blue_player[7][1]&&~blue_player[7][2]&&~blue_player[7][3]&&~blue_player[7][4]&&~blue_player[7][5];
assign five_blue[62] = ~blue_player[7][2]&&~blue_player[7][3]&&~blue_player[7][4]&&~blue_player[7][5]&&~blue_player[7][6];
assign five_blue[63] = ~blue_player[7][3]&&~blue_player[7][4]&&~blue_player[7][5]&&~blue_player[7][6]&&~blue_player[7][7];
//橫
assign five_blue[64] = ~blue_player[0][0]&&~blue_player[1][1]&&~blue_player[2][2]&&~blue_player[3][3]&&~blue_player[4][4];
assign five_blue[65] = ~blue_player[1][1]&&~blue_player[2][2]&&~blue_player[3][3]&&~blue_player[4][4]&&~blue_player[5][5];
assign five_blue[66] = ~blue_player[2][2]&&~blue_player[3][3]&&~blue_player[4][4]&&~blue_player[5][5]&&~blue_player[6][6];
assign five_blue[67] = ~blue_player[3][3]&&~blue_player[4][4]&&~blue_player[5][5]&&~blue_player[6][6]&&~blue_player[7][7];
	
assign five_blue[68] = ~blue_player[1][0]&&~blue_player[2][1]&&~blue_player[3][2]&&~blue_player[4][3]&&~blue_player[5][4];
assign five_blue[69] = ~blue_player[2][1]&&~blue_player[3][2]&&~blue_player[4][3]&&~blue_player[5][4]&&~blue_player[6][5];
assign five_blue[70] = ~blue_player[3][2]&&~blue_player[4][3]&&~blue_player[5][4]&&~blue_player[6][5]&&~blue_player[7][6];

assign five_blue[71] = ~blue_player[2][0]&&~blue_player[3][1]&&~blue_player[4][2]&&~blue_player[5][3]&&~blue_player[6][4];
assign five_blue[72] = ~blue_player[3][1]&&~blue_player[4][2]&&~blue_player[5][3]&&~blue_player[6][4]&&~blue_player[7][5];

assign five_blue[73] = ~blue_player[3][0]&&~blue_player[4][1]&&~blue_player[5][2]&&~blue_player[6][3]&&~blue_player[7][4];

assign five_blue[74] = ~blue_player[0][1]&&~blue_player[1][2]&&~blue_player[2][3]&&~blue_player[3][4]&&~blue_player[4][5];
assign five_blue[75] = ~blue_player[1][2]&&~blue_player[2][3]&&~blue_player[3][4]&&~blue_player[4][5]&&~blue_player[5][6];		 
assign five_blue[76] = ~blue_player[2][3]&&~blue_player[3][4]&&~blue_player[4][5]&&~blue_player[5][6]&&~blue_player[6][7];

assign five_blue[77] = ~blue_player[0][2]&&~blue_player[1][3]&&~blue_player[2][4]&&~blue_player[3][5]&&~blue_player[4][6];
assign five_blue[78] = ~blue_player[1][3]&&~blue_player[2][4]&&~blue_player[3][5]&&~blue_player[4][6]&&~blue_player[5][7];

assign five_blue[79] = ~blue_player[0][3]&&~blue_player[1][4]&&~blue_player[2][5]&&~blue_player[3][6]&&~blue_player[4][7];
//l斜  
assign five_blue[80] = ~blue_player[0][7]&&~blue_player[1][6]&&~blue_player[2][5]&&~blue_player[3][4]&&~blue_player[4][3];
assign five_blue[81] = ~blue_player[1][6]&&~blue_player[2][5]&&~blue_player[3][4]&&~blue_player[4][3]&&~blue_player[5][2];
assign five_blue[82] = ~blue_player[2][5]&&~blue_player[3][4]&&~blue_player[4][3]&&~blue_player[5][2]&&~blue_player[6][1];
assign five_blue[83] = ~blue_player[3][4]&&~blue_player[4][3]&&~blue_player[5][2]&&~blue_player[6][1]&&~blue_player[7][0];
		 
assign five_blue[84] = ~blue_player[1][7]&&~blue_player[2][6]&&~blue_player[3][5]&&~blue_player[4][4]&&~blue_player[5][3];
assign five_blue[85] = ~blue_player[2][6]&&~blue_player[3][5]&&~blue_player[4][4]&&~blue_player[5][3]&&~blue_player[6][2];
assign five_blue[86] = ~blue_player[3][5]&&~blue_player[4][4]&&~blue_player[5][3]&&~blue_player[6][2]&&~blue_player[7][1];

assign five_blue[87] = ~blue_player[2][7]&&~blue_player[3][6]&&~blue_player[4][5]&&~blue_player[5][4]&&~blue_player[6][3];
assign five_blue[88] = ~blue_player[3][6]&&~blue_player[4][5]&&~blue_player[5][4]&&~blue_player[6][3]&&~blue_player[7][2];

assign five_blue[89] = ~blue_player[3][7]&&~blue_player[4][6]&&~blue_player[5][5]&&~blue_player[6][4]&&~blue_player[7][3];

assign five_blue[90] = ~blue_player[0][6]&&~blue_player[1][5]&&~blue_player[2][4]&&~blue_player[3][3]&&~blue_player[4][2];
assign five_blue[91] = ~blue_player[1][5]&&~blue_player[2][4]&&~blue_player[3][3]&&~blue_player[4][2]&&~blue_player[5][1]; 
assign five_blue[92] = ~blue_player[2][4]&&~blue_player[3][3]&&~blue_player[4][2]&&~blue_player[5][1]&&~blue_player[6][0];

assign five_blue[93] = ~blue_player[0][5]&&~blue_player[1][4]&&~blue_player[2][3]&&~blue_player[3][2]&&~blue_player[4][1];
assign five_blue[94] = ~blue_player[1][4]&&~blue_player[2][3]&&~blue_player[3][2]&&~blue_player[4][1]&&~blue_player[5][0];

assign five_blue[95] = ~blue_player[0][4]&&~blue_player[1][3]&&~blue_player[2][2]&&~blue_player[3][1]&&~blue_player[4][0];

//r斜
assign blue_win = |five_blue;
///////////////////////////////////////////////////////////////

reg [3:0] a_count;//計時
divfreq2s F4(clk,clk_div2s);
always @(posedge clk_div2s, posedge reset,posedge enter)
begin//計時歸零狀況
	if(reset) a_count<=4'b0000;
	else if (enter) a_count<=4'b0000;
	else if (win) a_count<=4'b0000;
	else a_count <=a_count+1'b1;
	
end

bcd2seg B0(a_count[3],a_count[2],a_count[1],a_count[0],  a,b,c,d,e,f,g, ca,cb,cc,cd,ce,cf,cg);	 
reg a,b,c,d,e,f,g;
reg ca,cb,cc,cd,ce,cf,cg;
seg_timer B1(seg[0:6], seg7_com1,seg7_com2, clk, a,b,c,d,e,f,g, ca,cb,cc,cd,ce,cf,cg);


endmodule

module bcd2seg(input A,B,C,D, output reg a,b,c,d,e,f,g, ca,cb,cc,cd,ce,cf,cg);//數字圖形
	always @(A,B,C,D)
		begin
				case ({A,B,C,D})
					4'b0000:begin{a,b,c,d,e,f,g}=~7'b1111110;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0001:begin{a,b,c,d,e,f,g}=~7'b0110000;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0010:begin{a,b,c,d,e,f,g}=~7'b1101101;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0011:begin{a,b,c,d,e,f,g}=~7'b1111001;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0100:begin{a,b,c,d,e,f,g}=~7'b0110011;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0101:begin{a,b,c,d,e,f,g}=~7'b1011011;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0110:begin{a,b,c,d,e,f,g}=~7'b1011111;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b0111:begin{a,b,c,d,e,f,g}=~7'b1110000;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b1000:begin{a,b,c,d,e,f,g}=~7'b1111111;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
					4'b1001:begin{a,b,c,d,e,f,g}=~7'b1111011;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end//9
					4'b1010:begin{a,b,c,d,e,f,g}=~7'b1111110;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end
					4'b1011:begin{a,b,c,d,e,f,g}=~7'b0110000;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end
					4'b1100:begin{a,b,c,d,e,f,g}=~7'b1101101;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end
					4'b1101:begin{a,b,c,d,e,f,g}=~7'b1111001;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end
					4'b1110:begin{a,b,c,d,e,f,g}=~7'b0110011;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end
					4'b1111:begin{a,b,c,d,e,f,g}=~7'b1011011;{ca,cb,cc,cd,ce,cf,cg}=~7'b0110000;end//15
					default :begin{a,b,c,d,e,f,g}=7'b0000001;{ca,cb,cc,cd,ce,cf,cg}=7'b0000001;end
				endcase
		end
endmodule
		
module seg_timer (output reg [0:6] seg, output reg com1,com2, input clk, a,b,c,d,e,f,g, ca,cb,cc,cd,ce,cf,cg);//七段顯示掃描
	divfreq f0 (clk,clk_div);
	initial
		begin
			com1=1'b0;
			com2=1'b1;
		end
	always @(posedge clk_div)
		begin
			com1 = ~com1;
			com2 = ~com2;
			
			if(com1==0)
				seg={a,b,c,d,e,f,g};
			else
				seg={ca,cb,cc,cd,ce,cf,cg};
		end
endmodule

module divfreq(input clk,output reg clk_div);//掃描用頻
reg [24:0] count ;
always @(posedge clk)
	begin
		if(count>1000)
			begin
				count<=25'b0;
				clk_div<=~clk_div;
			end
		else
			count<=count+1'b1;
		end
endmodule

module divfreq2(input clk,output reg clk_div2);//~1sec
reg [24:0] count ;
always @(posedge clk)
	begin
		if(count>25000000)
			begin
				count<=25'b0;
				clk_div2<=~clk_div2;
			end
		else
			count<=count+1'b1;
		end
endmodule

module divfreq2s(input clk,output reg clk_div2s);//~2sec
reg [25:0] count ;
always @(posedge clk)
	begin
		if(count>50000000)
			begin
				count<=26'b0;
				clk_div2s<=~clk_div2s;
			end
		else
			count<=count+1'b1;
		end
endmodule

module divfreq3(input clk,output reg clk_div3);//上下左右移動速度
reg [24:0] count ;
always @(posedge clk)
	begin
		if(count>500000)
			begin
				count<=25'b0;
				clk_div3<=~clk_div3;
			end
		else
			count<=count+1'b1;
		end
endmodule