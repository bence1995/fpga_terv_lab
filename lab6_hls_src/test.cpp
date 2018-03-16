#include <stdio.h>
#include "fir.h"

#include "coeff_128.h"
#include "coeff_256.h"
#include "coeff_512.h"


int main()
{
	ap_uint<16> tlast_dnum;
	ap_uint<3> smpl_rd_num;
	ap_uint<9> tap_num_m1;
	din_t din_l;
	din_t din_r;
	out_stream_struct res;



	tlast_dnum = 16;
	smpl_rd_num = 1;
	tap_num_m1 = 127;

	for (int i = 0; i < (tap_num_m1 + 1) * 2; ++i)
	{

		if (i == 0)
		{
			din_l = 0.999999999999999;
			din_r = 0;
		}
		else
		{
			din_l = 0;
			din_r = 0;
		}

		fir_hw(tlast_dnum, smpl_rd_num, tap_num_m1, coeff_128, &din_l, &din_r, &res);

		printf("%d \t data: %1.23f\t tlast: %d \n", i, (double)res.tdata, (int)res.tlast);
	}

	return 0;
}
