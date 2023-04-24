function rateStudent(address student, uint256 rating) external { 
	require(bytes(studentProfiles[msg.sender].name).length != 0, "Student is not registered");

	num_rating = studentProfiles[student].totalRatings;
	new_rate = (studentProfiles[student].rating * num_rating + rating) / (num_rating + 1);
	
	studentProfiles[student].rating = new_rate;
	studentProfiles[student].totalRatings = num_rating + 1;
    emit UserRated(msg.sender, student, rating);
}
    
    
function reportChargerLost(uint256 chargerId) external { 
	price = chargers[chargerId].price;
	token_price = chargers[chargerId].tokenPrice;
	
	if balances[msg.sender] >= price:
		chargers[chargerId].functional = false;
		balances[msg.sender] -= price;
		owner = chargers[chargerId].owner;
		transferPayment(owner, price / token_price);
	else:
		deposit[msg.sender] -= price;
		owner = chargers[chargerId].owner;
		transferPayment(owner, price / token_price);
		
    emit ChargerReportedLost(chargerId, msg.sender);
}
    
    
function reportChargerDamaged(uint256 chargerId) external { 
	damageFine = chargers[chargerId].damageFine;
	token_price = chargers[chargerId].tokenPrice;
	
	if balances[msg.sender] >= damageFine:
		chargers[chargerId].functional = false;
		balances[msg.sender] -= damageFine;
		owner = chargers[chargerId].owner;
		transferPayment(owner, damageFine / token_price);
	else:
		deposit[msg.sender] -= damageFine;
		owner = chargers[chargerId].owner;
		transferPayment(owner, damageFine / token_price);
	
    emit ChargerReportedDamaged(chargerId, msg.sender);
}
