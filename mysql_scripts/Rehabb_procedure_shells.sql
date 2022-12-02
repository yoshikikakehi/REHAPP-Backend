use Rehapp;
##########################
# Patient store procedures

-- drop procedure if exists hashPassword;
-- DELIMITER //
-- create procedure hashPassword()
-- begin
-- 	update USERS set Pass=sha2(concat(Pass, salt), 256);
-- end//
-- DELIMITER ;

drop procedure if exists register;
DELIMITER //
create procedure register (
	in userEmail varchar(100),
    in pass varchar(100),
    in firstName varchar(100),
    in lastName varchar(100),
    in user_role enum('therapist', 'patient')
)
begin
	# given a user email and a password (pass has been hashed in the client side)
    # generate a salt for the user, then use SHA2_256 and the salt to hash the password
    # create a new user row with password = hashed password
    set @salt = substring(md5(rand()), -10);
    set @hashed_pass = SHA2(concat(pass, @salt), 256);

    insert into USERS (Email, Pass, FirstName, LastName, salt)
		values (userEmail, @hashed_pass, firstName, lastName, @salt);

    if (user_role = 'therapist') then
		insert into THERAPISTS values (userEmail);

    elseif (user_role = 'patient') then
		insert into PATIENTS values (userEmail, null);

    end if;

end //
DELIMITER ;

drop procedure if exists login;
DELIMITER //
create procedure login(
	in user_email varchar(100),
    in user_pass varchar(160)
)
begin
	drop table if exists loginResult;
    create table loginResult (
		Success bool not null,
        Reason varchar(100) not null,
        UserEmail varchar(100),
        FirstName varchar(100),
        LastName varchar(100),
        UserRole varchar(40)
    );

    if not exists (select * from USERS where USERS.Email=user_email) then
		insert into loginResult values (false, 'The user with the given email is not found', null, null, null, null);

	else
		select salt into @salt from USERS where USERS.Email=user_email;
        set @actual_password = SHA2(concat(user_pass, @salt), 256);
        select Pass into @expected_password from USERS where USERS.Email=user_email;

        if (@actual_password = @expected_password) then
			if exists (select * from THERAPISTS where THERAPISTS.Email=user_email) then
				set @role = 'therapist';
			elseif exists (select * from PATIENTS where PATIENTS.Email=user_email) then
				set @role = 'patient';
			end if;
            
			insert into loginResult select true, 'Success', USERS.Email, USERS.FirstName, USERS.LastName, @role
				from USERS where USERS.Email=user_email;
		else
			insert into loginResult values (false, 'Wrong password', null, null, null, null);
            
		end if;

    end if;
end //
DELIMITER ;

drop procedure if exists findUser;
DELIMITER //
create procedure findUser(
	in userEmail varchar(100)
)
begin
	drop table if exists findUserResult;
    create table findUserResult (
		Success bool not null,
        Reason varchar(100) not null,
        UserEmail varchar(100),
        FirstName varchar(100),
        LastName varchar(100),
        UserRole varchar(40) not null
    );

    if exists (select * from USERS where USERS.Email=userEmail) then
		if exists (select * from PATIENTS where PATIENTS.Email=userEmail) then
			insert into findUserResult select true, 'Success', USERS.Email, USERS.FirstName, USERS.LastName, 'patient'
				from USERS where USERS.Email=userEmail;
		elseif exists (select * from THERAPISTS where THERAPISTS.Email=userEmail) then
			insert into findUserResult select true, 'Success', USERS.Email, USERS.Firstname, USERS.LastName, 'therapist'
				from USERS where USERS.Email=userEmail;
		end if;

    else
		insert into findUserResult values (false, 'The user with the given email is not found', null, null, null, 'no role');

    end if;
end //
DELIMITER ;

drop procedure if exists getAssignedExercises;
DELIMITER //
create procedure getAssignedExercises (
	in patientEmail varchar(100)
)
begin
	drop table if exists getAssignedExercisesResult;
    create table getAssignedExercisesResult (
		Success bool not null,
        Reason varchar(100) not null,
		Therapist varchar(100),
        AssignmentID int,
        ExerciseName varchar(100),
        ExerciseDescription varchar(2000),
        ExercisePicture varchar(200),
        ExerciseVideo varchar(200),
        ExpectedDuration varchar(40),
        ExerciseFrequency varchar(100),
        ExerciseStatus varchar(100),
        ActualDuration varchar(100),
        ExerciseDifficulty varchar(100),
        ExerciseComment varchar(2000)
	);
    if not exists (select * from PATIENTS where Email=patientEmail) then
		insert into getAssignedExercisesResult values (false, 'The patient with the given email is not found', null, null, null, null, null, null, null, null, null, null, null, null);

    else
		insert into getAssignedExercisesResult
			select true, 'Sucess', Therapist, ID, ExerciseName, ExerciseDescription, ExercisePicture, ExerciseVideo, ExpectedDuration, ExerciseFrequency, ExerciseStatus, ActualDuration, ExerciseDifficulty, ExerciseComment
			from ASSIGNMENTS where Patient = patientEmail;
	end if;

end //
DELIMITER ;

drop procedure if exists createExerciseNote;
DELIMITER //
create procedure createExerciseNote (
	in patient varchar(100),
    in assignmentID int unsigned,
    in actualTime varchar(100),
    in exerciseDifficulty enum('EASY', 'MODERATE', 'HARD'),
    in exerciseComment varchar(2000)
)
begin
	drop table if exists createExerciseNoteResult;
    create table createExerciseNoteResult (
		Success bool not null,
        Reason varchar(100) not null
    );

	if not exists (select * from PATIENTS where Email=patient) then
		insert into createExerciseNoteResult values (false, 'The patient with the given email is not found');

    elseif not exists (select * from ASSIGNMENTS where ID=assignmentID) then
		insert into createExerciseNoteResult values (false, 'The assignment with the given ID is not found');

    else
		insert into createExerciseNoteResult values (true, 'Success');
		update ASSIGNMENTS set ExerciseStatus='COMPLETED', ActualDuration=actualTime, ExerciseDifficulty=exerciseDifficulty, ExerciseComment=exerciseComment
			where Patient=patient and ID=assignmentID;

    end if;
end //
DELIMITER ;

drop procedure if exists updateExerciseNote;
DELIMITER //
create procedure updateExerciseNote (
	in patient varchar(100),
    in assignmentID int unsigned,
    in actualTime varchar(100),
    in exerciseDifficulty enum('EASY', 'MODERATE', 'HARD'),
    in exerciseComment varchar(2000)
)
begin
	drop table if exists updateExerciseNoteResult;
    create table updateExerciseNoteResult (
		Success bool not null,
        Reason varchar(100) not null
    );

	if not exists (select * from PATIENTS where Email=patient) then
		insert into updateExerciseNoteResult values (false, 'The patient with the given email is not found');

    elseif not exists (select * from ASSIGNMENTS where ID=assignmentID) then
		insert into updateExerciseNoteResult values (false, 'The assignment with the given ID is not found');

    else
		insert into updateExerciseNoteResult values (true, 'Success');
		update ASSIGNMENTS set ExerciseStatus='COMPLETED', ActualDuration=actualTime, ExerciseDifficulty=exerciseDifficulty, ExerciseComment=exerciseComment
			where Patient=patient and ID=assignmentID;

    end if;
end //
DELIMITER ;

#####################################
# Therapist store procedures

drop procedure if exists searchPatient;
DELIMITER //
create procedure searchPatient (
    in patientEmail varchar(100)
)
begin
	drop table if exists searchPatientResult;
    create table searchPatientResult (
		Success bool not null,
        Reason varchar(100) not null,
        PatientEmail varchar(100),
        PatientFirstName varchar(100),
        PatientLastName varchar(100)
    );

    if exists (select * from PATIENTS where PATIENTS.Email=patientEmail and PATIENTS.Therapist is null) then
		insert into searchPatientResult (Success, Reason, PatientEmail, PatientFirstName, PatientLastName)
			select true, 'Success', patientEmail, USERS.FirstName, USERS.LastName
            from PATIENTS join USERS on PATIENTS.Email=USERS.Email
            where PATIENTS.Email=patientEmail;

	elseif exists (select * from PATIENTS where PATIENTS.Email=patientEmail) then
		insert into searchPatientResult (Success, Reason, PatientEmail, PatientFirstName, PatientLastName)
			values (false, 'The patient with the given email has already been assigned to a therapist', patientEmail, null, null);

	else
		insert into searchPatientResult (Success, Reason, PatientEmail, PatientFirstName, PatientLastName)
			values (false, 'The patient with the given email is not found', patientEmail, null, null);

	end if;
end //
DELIMITER ;

drop procedure if exists addPatient;
DELIMITER //
create procedure addPatient (
	therapistEmail varchar(100),
    patientEmail varchar(100)
)
main: begin
	drop table if exists addPatientResult;
    create table addPatientResult (
		Success bool not null,
        Reason varchar(100) not null
    );
	if not exists (select * from PATIENTS where Email=patientEmail) then
		insert into addPatientResult values (false, 'A patient with the given email is not found');
        leave main;
	end if;

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into addPatientResult values (false, 'A therapist with the given email is not found');
		leave main;
    end if;

    update PATIENTS set PATIENTS.Therapist=therapistEmail where PATIENTS.Email=patientEmail;
    insert into addPatientResult values (true, 'Success');

end //
DELIMITER ;

drop procedure if exists deletePatient;
DELIMITER //
create procedure deletePatient (
    in patientEmail varchar(100)
)
begin
	drop table if exists deletePatientResult;
    create table deletePatientResult (
		Success bool not null,
        Reason varchar(100) not null,
        PatientEmail varchar(100),
        PatientFirstName varchar(100),
        PatientLastName varchar(100)
    );

    if exists (select * from PATIENTS where PATIENTS.Email=patientEmail) then
		insert into deletePatientResult (Success, Reason, PatientEmail, PatientFirstName, PatientLastName)
			select true, 'Success', patientEmail, USERS.FirstName, USERS.LastName
			from USERS where USERS.Email=patientEmail;
		update PATIENTS set PATIENTS.Therapist=null where PATIENTS.Email=patientEmail;
        
		## Should the patient be able to see the exercises that her therapist assigned to her after the thera pist deletes the patient?
		# delete from ASSIGNMENTS where ASSIGNMENTS.Patient = patientEmail;

	else
		insert into deletePatientResult (Success, Reason, PatientEmail, PatientFirstName, PatientLastName)
			values (false, 'The patient with the given email is not found', patientEmail, null, null);

	end if;
end //
DELIMITER ;

drop procedure if exists getPatients;
DELIMITER //
create procedure getPatients (
	in therapistEmail varchar(100)
)
/*
	Given a therapist email, return all patients under the given therapist
*/
begin
	drop table if exists getPatientsResult;
    create table getPatientsResult (
		Success bool not null,
        Reason varchar(100) not null,
        PatientEmail varchar(100),
        PatientFirstName varchar(100),
        PatientLastName varchar(100)
    );

    if exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into getPatientsResult select true, 'Success', PATIENTS.Email, USERS.FirstName, USERS.LastName
			from PATIENTS join USERS where PATIENTS.Therapist=therapistEmail and PATIENTS.Email=USERS.Email;
    else
		insert into getPatientsResult values (false, 'A therapist with the given email does not exist', null, null, null);
	end if;
end //
DELIMITER ;

drop procedure if exists getPatientAssignments;
DELIMITER //
create procedure getPatientAssignments (
	in therapistEmail varchar(100),
    in patientEmail varchar(100)
)
/*
	Given a therapist and a patient, return all assignments that this therapist has given to the patient
    TODO: error case where the given patient is not associated with the given therapist
*/
begin
	drop table if exists getPatientAssignmentsResult;
    create table getPatientAssignmentsResult (
		Success bool not null,
        Reason varchar(100) not null,
        TherapistEmail varchar(100),
        PatientEmail varchar(100),
        AssignmentID int unsigned,
        ExerciseName varchar(100),
        ExerciseDescription varchar(2000),
        ExercisePicture varchar(200),
        ExerciseVideo varchar(200),
        ExpectedTime varchar(100),
        ExerciseFrequency varchar(100),
        ExerciseStatus enum('ASSIGNED', 'COMPLETED') not null,
		ReportedDuration varchar(100),
		ReportedDifficulty enum('EASY', 'MODERATE', 'HARD'),
		PatientComment varchar(2000)
    );

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into getPatientAssignmentsResult
			values (false, 'The therapist with the given email is not found', therapistEmail, patientEmail, null, null, null, null, null, null, null, null, null, null, null);
    elseif not exists (select * from PATIENTS where Email=patientEmail) then
		insert into getPatientAssignmentsResult
			values (false, 'The patient with the given email is not found', therapistEmail, patientEmail, null, null, null, null, null, null, null, null, null, null, null);
    else
		insert into getPatientAssignmentsResult
			select true, 'Success', therapistEmail, patientEmail, ASSIGNMENTS.ID, ASSIGNMENTS.ExerciseName, ASSIGNMENTS.ExerciseDescription, ASSIGNMENTS.ExercisePicture, ASSIGNMENTS.ExerciseVideo, 
            ASSIGNMENTS.ExpectedDuration, ASSIGNMENTS.ExerciseFrequency, ASSIGNMENTS.ExerciseStatus, ASSIGNMENTS.ActualDuration, ASSIGNMENTS.ExerciseDifficulty, ASSIGNMENTS.ExerciseComment
			from ASSIGNMENTS where Therapist=therapistEmail and Patient=patientEmail;
	end if;
end //
DELIMITER ;

drop procedure if exists createPatientAssignment;
DELIMITER //
create procedure createPatientAssignment (
	 in therapistEmail varchar(100),
     in patientEmail varchar(100),
     in exerciseID int unsigned,
     in exerciseName varchar(100),
     in exerciseDescription varchar (2000),
     in exercisePicture varchar(200),
     in exerciseVideo varchar(200),
     in expectedDuration varchar(100),
     in exerciseFrequency varchar(100)
)
/*
	Given therapist email, patient email, and assignment content, create a new assignment
*/
begin
	drop table if exists createPatientAssignmentResult;
    create table createPatientAssignmentResult (
		Success bool not null,
        Reason varchar(100) not null
    );

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into createPatientAssignmentResult values (false, 'The therapist with the given email is not found');

    elseif not exists (select * from PATIENTS where Email=patientEmail) then
		insert into createPatientAssignmentResult values (false, 'The patient with the given email is not found');

    elseif not exists (select * from PATIENTS where Email=patientEmail and Therapist=therapistEmail) then
		insert into createPatientAssignmentResult values (false, 'The patient with the given email is not associated with the therapist with the given email');

	else
		insert into createPatientAssignmentResult values (true, 'Success');
		insert into ASSIGNMENTS (Patient, Therapist, ExerciseID, ExerciseName, ExerciseDescription, ExercisePicture, ExerciseVideo, ExpectedDuration, ExerciseFrequency, ExerciseStatus)
			values (patientEmail, therapistEmail, exerciseID, exerciseName, exerciseDescription, exercisePicture, exerciseVideo, expectedDuration, exerciseFrequency, 'ASSIGNED');

    end if;
end //
DELIMITER ;

drop procedure if exists modifyPatientAssignment;
DELIMITER //
create procedure modifyPatientAssignment (
	in assignmentID int unsigned,
	in therapistEmail varchar(100),
	in patientEmail varchar(100),
	in exerciseName varchar(100),
	in exerciseDescription varchar (2000),
	in exerciseVideo varchar(200),
	in expectedDuration varchar(200),
	in exerciseFrequency varchar(100)
)
begin
	drop table if exists modifyPatientAssignmentResult;
    create table modifyPatientAssignmentResult (
		Success bool not null,
        Reason varchar(100) not null
    );

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into modifyPatientAssignmentResult values (false, 'The therapist with the given email is not found');

    elseif not exists (select * from PATIENTS where Email=patientEmail) then
		insert into modifyPatientAssignmentResult values (false, 'The patient with the given email is not found');

    elseif not exists (select * from PATIENTS where Email=patientEmail and Therapist=therapistEmail) then
		insert into modifyPatientAssignmentResult values (false, 'The patient with the given email is not associated with the therapist with the given email');

    elseif not exists (select * from ASSIGNMENTS where ID=assignmentID) then
		insert into modifyPatientAssignmentResult values (false, 'The exercise assignment with the given ID is not found');

	else
		insert into modifyPatientAssignmentResult values (true, 'Success');
        update ASSIGNMENTS set ExerciseName=exerciseName, ExerciseDescription=exerciseDescription,
			ExerciseVideo=exerciseVideo, ExpectedDuration=expectedDuration, ExerciseFrequency=exerciseFrequency
            where ID=assignmentID and Patient=patientEmail and Therapist=therapistEmail;

    end if;
end //
DELIMITER ;

drop procedure if exists deletePatientAssignment;
DELIMITER //
create procedure deletePatientAssignment (
	in therapistEmail varchar(100),
    in assignmentID int
)
/*
	Delete the assignment with a given ID
*/
begin
	drop table if exists deletePatientAssignmentResult;
    create table deletePatientAssignmentResult (
		Success bool not null,
        Reason varchar(100) not null
    );

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into deletePatientAssignmentResult values (false, 'The therapist with the given email is not found');

    elseif not exists (select * from ASSIGNMENTS where ID=assignmentID) then
		insert into deletePatientAssignmentResult values (false, 'The assignment with the given ID is not found');

    elseif not exists (select * from ASSIGNMENTS where Therapist=therapistEmail and ID=assignmentID) then
		insert into deletePatientAssignmentResult values (false, 'The therapist does not have any assignments with a matching ID');
	
    else
		delete from ASSIGNMENTS where ID=assignmentID and Therapist=therapistEmail;
        insert into deletePatientAssignmentResult values (true, 'Success');
        
    end if;
end //
DELIMITER ;

drop procedure if exists getExerciseBank;
DELIMITER //
create procedure getExerciseBank(
	in therapistEmail varchar(100)
)
/*
	Return a list of all exercises in the exercise bank
*/
begin
	drop table if exists getExerciseBankResult;
    create table getExerciseBankResult (
		Success bool not null,
        Reason varchar(100) not null,
        ExID int,
        ExName varchar(100),
        ExDescription varchar(2000),
        ExPicture varchar(200),
        ExVideo varchar(200),
        ExTime varchar(100),
        ExFrequency varchar(100)
    );

    if not exists (select * from THERAPISTS where Email=therapistEmail) then
		insert into getExerciseBankResult values (false, 'The therapist with the given email is not found', null, null, null, null, null, null, null);

    else
		insert into getExerciseBankResult
			select true, 'Sucess', ID, ExerciseName, ExerciseDescription, Picture, Video, Duration, Frequency
			from EXERCISES;

    end if;

end //
DELIMITER ;
