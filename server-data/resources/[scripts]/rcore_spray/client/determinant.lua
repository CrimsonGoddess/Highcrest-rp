--[[
    Matrix Determinant Calculation Module
    Implements Johnson-Trotter algorithm for permutation generation
    and matrix determinant calculation used for checking if points are coplanar.
]]

--[[
    Johnson-Trotter Algorithm for Permutation Generation
    This is used to generate all permutations of numbers 1 through n
    efficiently for computing matrix determinants via Leibniz formula.
]]
local JT = {}
local _JT = {}

-- Constructor: Creates a new permutation generator for numbers 1 through size
-- @param size: The number of elements to permute (typically the matrix size)
function JT(size)
    local permutationState = {
        values = {},      -- Array of values [1, 2, 3, ..., size]
        positions = {},   -- Current position of each value in the permutation
        directions = {},  -- Direction each element is moving (-1 or 1)
        sign = 1          -- Current sign of the permutation (-1 or 1)
    }
    
    -- Set up metatable for the permutation state
    setmetatable(permutationState, { __index = _JT })
    
    -- Initialize all arrays
    for i = 1, size do
        permutationState.values[i] = i
        permutationState.positions[i] = i
        permutationState.directions[i] = -1  -- All start moving left
    end
    
    return permutationState
end

-- Finds the largest mobile element (element that can move in its current direction)
-- An element is mobile if it's larger than the element it's pointing to
-- @return: Index of largest mobile element, or 0 if none exists
function _JT:largestMobile()
    local values = self.values
    local positions = self.positions
    local directions = self.directions
    local size = #values
    
    -- Search from largest to smallest
    for i = size, 1, -1 do
        local currentPos = positions[i]
        local direction = directions[i]
        local newPos = currentPos + direction
        
        -- Check if element can move in this direction
        if newPos >= 1 and newPos <= size then
            local valueAtNewPos = values[newPos]
            -- Element is mobile if it's larger than the one it's moving toward
            if i > valueAtNewPos then
                return i
            end
        end
    end
    
    return 0
end

-- Generates the next permutation in lexicographic order
-- @return: true if a next permutation exists, false if all permutations have been generated
function _JT:next()
    local largestMobileIdx = self:largestMobile()
    
    if largestMobileIdx == 0 then
        return false  -- No more permutations
    end
    
    local currentPos = self.positions[largestMobileIdx]
    local direction = self.directions[largestMobileIdx]
    local newPos = currentPos + direction
    local valueAtNewPos = self.values[newPos]
    
    -- Swap the values
    self.values[currentPos], self.values[newPos] = self.values[newPos], self.values[currentPos]
    
    -- Swap the positions
    self.positions[largestMobileIdx], self.positions[valueAtNewPos] = self.positions[valueAtNewPos], self.positions[largestMobileIdx]
    
    -- Flip the sign (each swap changes the sign of the permutation)
    self.sign = -self.sign
    
    -- Reverse directions of all elements larger than the moved element
    for i = largestMobileIdx + 1, #self.directions do
        self.directions[i] = -self.directions[i]
    end
    
    return true
end

--[[
    Matrix class for determinant calculation
    Stores a matrix as a 2D array and provides methods for determinant computation
]]
local MTX = {}
local _MTX = {}

-- Constructor: Creates a matrix from a 2D array
function MTX(matrixArray)
    setmetatable(matrixArray, { __index = _MTX })
    matrixArray.rows = #matrixArray
    matrixArray.cols = #matrixArray[1]
    return matrixArray
end

-- Debug function: Prints the matrix
function _MTX:dump()
    for _, row in ipairs(self) do
        print(unpack(row))
    end
end

-- Calculates the permanent of the matrix (determinant without alternating signs)
function _MTX:perm()
    return self:det(1)
end

-- Calculates the determinant of the matrix using Leibniz formula
-- @param signMultiplier: Optional sign multiplier (defaults to permutation sign)
-- @return: The determinant value
function _MTX:det(signMultiplier)
    local determinant = 0
    local permutationGen = JT(self.cols)
    
    repeat
        local sign = signMultiplier or permutationGen.sign
        if not signMultiplier then
            sign = permutationGen.sign
        end
        
        -- Multiply elements according to the current permutation
        local product = sign
        for idx, pos in ipairs(permutationGen.values) do
            product = product * self[idx][pos]
        end
        
        determinant = determinant + product
    until not permutationGen:next()
    
    return determinant
end

--[[
    Checks if 6 points are coplanar (lie on the same plane)
    Uses determinant calculation: points are coplanar if the determinant of
    a matrix formed from them is approximately zero.
    
    @param p1, p2, p3, p4, p5, p6: vector3 points
    @return: true if points are coplanar (within 掠 tolerance)
]]
function IsOnPlane(p1, p2, p3, p4, p5, p6)
    -- Create first matrix from points 1-4 with homogeneous coordinates (w=1)
    local matrix1 = MTX({
        {p1.x, p2.x, p3.x, p4.x},
        {p1.y, p2.y, p3.y, p4.y},
        {p1.z, p2.z, p3.z, p4.z},
        {1, 1, 1, 1}
    })
    
    -- Create second matrix from points 1, 3, 5, 6 with homogeneous coordinates
    local matrix2 = MTX({
        {p1.x, p3.x, p5.x, p6.x},
        {p1.y, p3.y, p5.y, p6.y},
        {p1.z, p3.z, p5.z, p6.z},
        {1, 1, 1, 1}
    })
    
    -- Points are coplanar if the absolute value of the determinant is very small
    local determinant = math.abs(matrix1:det())
    local threshold = 0.1
    
    return determinant < threshold
end

-- Command to display license information (if configured)
RegisterCommand('rcsprayshowlicense', function()
    print(Config.License)
end)
