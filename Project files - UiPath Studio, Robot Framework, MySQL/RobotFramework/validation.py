def isReferenceCorrect(referencenumber):

    listedRef = list(referencenumber)

    #print(listedRefNumber)
    checknumber = listedRef.pop()
    totalAmount = 0
    product = 1

    while (len(listedRef) > 0):
        if ( product == 1):
            product = 7
            totalAmount = totalAmount + (product * int(listedRef.pop()))
        elif (product == 3):
            product = 1
            totalAmount = totalAmount + (product * int(listedRef.pop()))
        else:
            product = 3
            totalAmount = totalAmount + (product * int(listedRef.pop()))

    #print(totalAmount)

    result = (10 - (totalAmount % 10)) % 10

    if (result == int(checknumber)):
        return True
    
    return False

def isEqual(headerTotal, rowTotal, maxDifference):
    if ( abs(headerTotal-rowTotal) < maxDifference ):
        return True
    return False

if __name__=="__main__":
    ref = '217356'
    val = isReferenceCorrect(ref)
    print(val)