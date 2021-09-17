#include <stdio.h>
#include <stdlib.h>

int main()
{
  int row;

  printf("Enter a row index: ");
  scanf("%d",&row);

  int n=row+1;
  for(int i=0;i<n;i++)
    {
      int unsigned long long term=1;
      for(int j=1;j<=i;j++)
	{
	  if(i==0)continue;
	  else 
	    {
	      term=(term*(row+1-j))/j;
	    }
	}
      printf("%lld ",term);
    }

  return 0;
}
