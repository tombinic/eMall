-- Signatures

sig Username {}
sig Password {}
sig Email {}
sig Name {}
sig Surname {}
sig BusinessData {}
sig DSOId {}
sig DSOName {}
sig SocketPrice {}
sig DSOPrice {}
sig CardNumber {}
sig Cvv {}
sig Date {}
sig ExpiredDate {}
sig BookingCode {}
sig ChargingStationId {}
sig ChargingStationName {}
sig Address {}
sig BatteryClusterPercentage {}
sig BatteryClusterCapacity {}
abstract sig BookingStatus {}
one sig Valid extends BookingStatus {}
one sig Expired extends BookingStatus {}
abstract sig ChargingSocketStatus {}
one sig Free extends ChargingSocketStatus {}
one sig Busy extends ChargingSocketStatus {}
abstract sig SocketType {}
one sig Slow, Fast, Rapid extends SocketType {}

abstract sig User {
	username: Username,		
	password: Password,
	email: Email,
	name: Name,
	surname: Surname
}

sig EndUser extends User {
	paymentMethod: some PaymentMethod
}
	
sig PaymentMethod {
	cardNumber: CardNumber,
	cvv: Cvv,
	expireDate: ExpiredDate
}

sig ChargingStation {
	id: ChargingStationId,
	name: ChargingStationName,
	address: Address,
	batteryClusterPercentage: one BatteryClusterPercentage,
	batteryClusterCapacity: one BatteryClusterCapacity,
	sockets: some ChargingSocket
}

sig ChargingSocket {
	number: one Int,
	type: SocketType,
	status: ChargingSocketStatus,
	price: SocketPrice
} { number >= 1 }
	
sig DSO {
	id: DSOId,
	name: DSOName,
	energyPrice: DSOPrice
}

sig CPO extends User {
	businessData: BusinessData,
	stations: some ChargingStation,
	CPO_DSOs: some DSO
}

sig Booking {
	code: BookingCode,
	date: Date,
	socketNumber: one ChargingSocket,
	start: one Int,
	end: one Int,
	user: one EndUser,
	station: one ChargingStation,
	status: BookingStatus
} {start < end && start >= 0 && end <= 24 }

-- Facts

-- User
fact usernamesAreUnique {
	no disj u1, u2: User | u1.username = u2.username
}

fact emailsAreUnique {
	no disj u1, u2: User | u1.email = u2.email
}

fact usernameExistsOnlyWithUser {
	all un: Username | one u: User | un in u.username
}

fact emailExistsOnlyWithUser {
	all el: Email | one u: User | u.email in el
}

fact passwordExistsOnlyWithUser {
	all pw: Password | one u: User | u.password in pw
}

fact nameExistsOnlyWithUser {
	all nm: Name | one u: User | u.name in nm
}

fact surnameExistsOnlyWithUser {
	all sm: Surname | one u : User | u.surname in sm
}

-- CPO
fact businessDataAreUnique {
	no disj c1, c2: CPO | c1.businessData = c2.businessData
}

fact businessDataExistsOnlyWithCpo {
	all bd: BusinessData | one cpo: CPO | cpo.businessData in bd
}

fact chargingStationsExistsOnlyWithCpo {
	all cg: ChargingStation | one cpo: CPO | cg in cpo.stations
}

-- Booking
fact allBookingsAreUnique {
	no disj b1, b2: Booking | b1.code = b2.code
}

fact noBookingOverlapping {
	all disj b1, b2 : Booking | not (b1.date = b2.date && b1.station = b2.station && b1.socketNumber = b2.socketNumber && 
					       b2.start >= b1.start && b2.end <= b1.end  ||
					       b2.start >= b1.start && b2.end >= b1.end && b2.start < b1.end  ||
					       b2.start =< b1.start && b2.end >= b1.end  ||
 					       b2.start =< b1.start && b2.end =< b1.end && b1.start  < b2.end)
}

fact codeExistsOnlyWithBooking {
	all cd: BookingCode | one b: Booking | cd in b.code
}

fact onlyOneBookingStatusAtTime {
	all b: Booking | one bst: BookingStatus | bst in b.status
}

-- Charging Station
fact chargingStationIdAreUnique {
	no disj cs1, cs2: ChargingStation | cs1.id = cs2.id
}

fact chargingStationAddressesAreUnique {
	no disj cs1, cs2: ChargingStation | cs1.address = cs2.address
}

fact oneChargingStationBelongToOneCPO {
	all cs: ChargingStation | one c: CPO | cs in c.stations
}

fact nameExistsOnlyWithChargingStation {
	all nm: ChargingStationName | one cs: ChargingStation | nm in cs.name
}

fact idExistsOnlyWithChargingStation {
	all i: ChargingStationId | one cs: ChargingStation | i in cs.id
}

fact addressExistsOnlyWithChargingStation {
	all addr: Address | one cs: ChargingStation | addr in cs.address
}

fact batteryClusterPercentageExistsOnlyWithChargingStation {
	all bcp: BatteryClusterPercentage | one cs: ChargingStation | bcp in cs.batteryClusterPercentage
}

fact batteryClusterCapacityExistsOnlyWithChargingStation {
	all bcc: BatteryClusterCapacity | one cs: ChargingStation | bcc in cs.batteryClusterCapacity
}

-- Charging Socket
fact socketIdAreUnique {
	no disj cs1, cs2: ChargingSocket | one cs: ChargingStation | cs1.number = cs2.number && cs1 in cs.sockets && cs2 in cs.sockets
}

fact oneChargingSocketBelongToOneChargingStation {
	all csk: ChargingSocket | one cs: ChargingStation | csk in cs.sockets
}

fact priceExistsOnlyWithChargingSocket {
	all pr: SocketPrice | one cs: ChargingSocket | pr in cs.price
}

fact onlyOneStatusAtTime {
	all cs: ChargingSocket | one css: ChargingSocketStatus | css in cs.status
}

-- Payment Method
fact paymentMethodExistsOnlyWithEndUser {
	all pm: PaymentMethod | some u: EndUser | pm in u.paymentMethod
}

fact numberExistsOnlyWithPaymentMethod {
	all cn: CardNumber | one pm: PaymentMethod | cn in pm.cardNumber
}

fact cvvExistsOnlyWithPaymentMethod {
	all cv: Cvv | one pm: PaymentMethod | cv in pm.cvv
}

fact dateExistsOnlyWithPaymentMethod {
	all dt: ExpiredDate | one pm: PaymentMethod | dt in pm.expireDate
}

-- DSO
fact idExistsOnlyWithDSO {
	all i: DSOId | one dso: DSO | i in dso.id
}

fact nameExistsOnlyWithDSO {
	all nm: DSOName | one dso: DSO | nm in dso.name
}

fact energyPriceExistsOnlyWithDSO {
	all ep: DSOPrice | one dso: DSO | ep in dso.energyPrice
}

-- Predicates

pred world1 {
	#Booking = 2
	#EndUser = 1
	#ChargingStation = 1
	#ChargingSocket = 1
	#Date = 1
	#DSO = 1

	all b: Booking |  (b.status = Valid)
	all cs: ChargingSocket |  (cs.status = Free or cs.status = Busy)
	all cs: ChargingSocket |  (cs.type = Fast or cs.type = Slow or cs.type = Rapid)
}

run world1 for 4 but 6 Int


pred world2 {
	#ChargingStation = 2
	#ChargingSocket = 6
	#CPO = 2
	#DSO = 1
	#Date = 0
	#EndUser = 0

	all cs: ChargingSocket |  (cs.status = Busy or cs.status = Free)
	all cs: ChargingSocket |  (cs.type = Slow or cs.type = Fast or cs.type = Rapid)
}

run world2 for 6

-- Assertions

assert allBookingsNoOverlapped {
	all disj b1, b2 : Booking | ((b1.date != b2.date || b1.station != b2.station || b1.socketNumber != b2.socketNumber) || 
					       b2.start >= b1.end || b1.start >= b2.end)
}
check allBookingsNoOverlapped

assert noEqualChargingSocketInSameChargingStation {
	all disj cs1, cs2: ChargingSocket | all cs: ChargingStation |  ((cs1 in cs.sockets && cs2 in cs.sockets) implies cs1.number != cs2.number)
}
check noEqualChargingSocketInSameChargingStation
