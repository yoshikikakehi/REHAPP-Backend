class Patient {
    constructor(Email, FirstName, LastName) {
        this.email = Email;
        this.firstname = FirstName;
        this.lastname = LastName;
        this.role = 'patient'
    }
}

module.exports = Patient;