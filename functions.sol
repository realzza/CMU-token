function rateStudent(address student, uint256 rating) external { 
	require(bytes(studentProfiles[msg.sender].name).length != 0, "Student is not registered");
	// check if the student actually rented the charger

	num_rating = studentProfiles[student].totalRatings;
	new_rate = (studentProfiles[student].rating * num_rating + rating) / (num_rating + 1);
	
	studentProfiles[student].rating = new_rate;
	studentProfiles[student].totalRatings = num_rating + 1;
    emit UserRated(msg.sender, student, rating);
}
    
    
function reportChargerLost(uint256 chargerId) external { 
	price = chargers[chargerId].price;
	require(balances[msg.sender] >= price, "Insufficient balance for charger price");
	chargers[chargerId].functional = false;
	
	balances[msg.sender] -= price;
	owner = chargers[chargerId].owner;
	transferPayment(owner, price);
    
    emit ChargerReportedLost(chargerId, msg.sender);
}
    
    
function reportChargerDamaged(uint256 chargerId) external { 
	damageFine = chargers[chargerId].damageFine;
	require(balances[msg.sender] >= damageFine, "Insufficient balance for damage fine");
	chargers[chargerId].functional = false;
	
	balances[msg.sender] -= damageFine;
	owner = chargers[chargerId].owner;
	transferPayment(owner, damageFine);
	
    emit ChargerReportedDamaged(chargerId, msg.sender);
}

// return: booking.isactive set to inactive?
// change tokens when transfer fine/charger price