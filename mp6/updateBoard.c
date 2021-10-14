/*  ECE 220 MP6 - GAME OF LIFE
*The game of life updates a game board according to certain conditions
*It revives the cell if it has 3 neighbours, kills it if it has 1 or 0 neighbours and
*kills it if it has more than 3 neighbours. With 2 or 3 neighbours, the cell stays alive
*We created a count live neighbours function to find number of live neighbours to determine fate of cell
*Using that function and if the cell is alive , we use these conditions to update the board.
*If the updated board is same as the original board, the update board funtion will return 1 and the game will finish.
*/

/*
 * countLiveNeighbor
 * Inputs:
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * row: the row of the cell that needs to count alive neighbors.
 * col: the col of the cell that needs to count alive neighbors.
 * Output:
 * return the number of alive neighbors. There are at most eight neighbors.
 * Pay attention for the edge and corner cells, they have less neighbors.
 */

int countLiveNeighbor(int* board, int boardRowSize, int boardColSize, int row, int col)
{
//Set Number of Live Neighbours to 0
    int count = 0;

    //rows from currRow-1 to currRow+1, inclusive
	for(int i = row-1; i <= row+1; i++)
    {
        //check if the row is within the bounds of the board
		if(i >= 0 && i < boardRowSize)
        {
            //columns from currCol-1 to currCol+1, inclusive
			for(int j = col-1; j <= col+1; j++)
            {
                //Check if the column is within the bounds of the board
				if( j >= 0 && j < boardColSize)
                {
                    //Check  if the cell isn't at (currRow, currCol)
					if(!(i == row && j == col))
                    {
                        //Check if the cell is alive
						if(board[i*boardColSize+j] == 1)
                        {
                            //increment the number of live neighbors
							count++;
						}
					}
				}
			}
		}
	}
     //return the number of live neighbors
	return count;  
}
/*
 * Update the game board to the next step.
 * Input: 
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * Output: board is updated with new values for next step.
 */
void updateBoard(int* board, int boardRowSize, int boardColSize) 
{
    //create a new 2-d array copy
    int copy[boardRowSize][boardColSize];   
    for(int i = 0; i < boardRowSize; i++)
    {
        for(int j = 0; j < boardColSize; j++)
        {
        //Update copy with values of game board
        copy[i][j] = board[(i*boardColSize)+j];
        }
    }

   
    for(int i = 0; i < boardRowSize; i++)
    {
        for(int j = 0; j < boardColSize; j++)
        {
            //count live neighbours of every element on game board
            int livecount = countLiveNeighbor(board, boardRowSize, boardColSize, i, j);
            //check if element on its own is alive
            if(board[(i*boardColSize)+j] == 1)
            {
                //Under-population condition
                if(livecount < 2)
                {
                    copy[i][j] = 0;
               
                }
                //Over-population condition
                else if (livecount > 3)
                {
                   copy[i][j] = 0;
                }
            
            }   
            //reproduction condition
            else if (livecount == 3)
            {
                copy[i][j] = 1;
            }
        }
    }
    //update board with updated values from copy
    for(int i = 0; i < boardRowSize; i++)
    {
        for(int j = 0; j < boardColSize; j++)
        {
        board[(i*boardColSize)+j]=copy[i][j];
        }
    }

}



/*
 * aliveStable
 * Checks if the alive cells stay the same for next step
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * Output: return 1 if the alive cells for next step is exactly the same with 
 * current step or there is no alive cells at all.
 * return 0 if the alive cells change for the next step.
 */ 
int aliveStable(int* board, int boardRowSize, int boardColSize)
{
      //calculate size of board array
	int size = boardColSize * boardRowSize;
    //create new array with the same size as board array
    int new[size];

    //copy the game board into the new array
    for(int k = 0; k < size; k++){
        new[k] = board[k];
    }

    //update new array with the next state of the game of life
    updateBoard(new, boardRowSize, boardColSize);

    //check if new array is equal to the original board
    for(int k = 0; k < size; k++){
        //return 0 if any element of board and new array is different
        if(board[k] != new[k]){
            return 0;
        }
    }
    //return 1 if board and new array are the same
    return 1;

}

				
				
			

