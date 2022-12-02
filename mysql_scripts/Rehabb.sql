/* Rehapp database initialization */

drop database if exists Rehapp;
create database if not exists Rehapp;
use Rehapp;

Create table USERS (
	Email varchar(40) not null,
    Pass varchar(256) not null,
    FirstName varchar(40) not null,
    LastName varchar(40) not null,
    salt varchar(40) not null,
    primary key (Email)
);

Create table THERAPISTS (
	Email varchar(40) not null,
    foreign key (Email) references USERS(Email),
    primary key (Email)
);

Create table PATIENTS (
	Email varchar(40) not null,
    Therapist varchar(40),
    foreign key (Email) references USERS(Email),
    foreign key (Therapist) references THERAPISTS(Email),
    primary key (Email)
);

Create table EXERCISES (
	ID int unsigned auto_increment not null,
    ExerciseName varchar(100) not null,
    ExerciseDescription varchar(2000) not null,
    Picture varchar(400),
    Video varchar(400),
    Duration varchar(100) not null,
    Frequency varchar(100) not null,
    primary key (ID)
);

Create table ASSIGNMENTS (
	ID int unsigned auto_increment not null,
    Patient varchar(100) not null,
    Therapist varchar(100) not null,
    ExerciseID int unsigned,
    ExerciseName varchar(100) not null,
    ExerciseDescription varchar(2000) not null,
    ExercisePicture varchar(200),
    ExerciseVideo varchar(200),
    ExpectedDuration varchar(100) not null,
    ExerciseFrequency varchar(100) not null,
    ExerciseStatus enum('ASSIGNED', 'COMPLETED') not null,
    ActualDuration varchar(100),
    ExerciseDifficulty enum('EASY', 'MODERATE', 'HARD'),
    ExerciseComment varchar(2000),
    primary key (ID),
    foreign key (ExerciseID) references EXERCISES(ID),
    foreign key (Patient) references PATIENTS(Email),
    foreign key (Therapist) references THERAPISTS(Email)
);

insert into USERS (Email, Pass, FirstName, LastName, salt) values
('emma@gmail.com', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'Emma', 'Dang', 'bf66acf47f'), # password1
('andrew@gmail.com', '6cf615d5bcaac778352a8f1f3360d23f02f34ec182e259897fd6ce485d7870d4', 'Andrew', 'Xu', 'e12e047e7a'), # password2
('aditi@gmail.com', '5906ac361a137e2d286465cd6588ebb5ac3f5ae955001100bc41577c3d751764', 'Aditi', 'Bhatia', '5384b2ee19'), # password3
('jessica@gmail.com', 'b97873a40f73abedd8d685a7cd5e5f85e4a9cfb83eac26886640a0813850122b', 'Jessica', 'Jacobs', 'bebac51c2b'), # password4
('paula@gmail.com', '8b2c86ea9cf2ea4eb517fd1e06b74f399e7fec0fef92e3b482a6cf2e2b092023', 'Paula', 'Punmaneeluk', 'a28f3a0e88'), # password5
('rishabh@gmail.com', '598a1a400c1dfdf36974e69d7e1bc98593f2e15015eed8e9b7e47a83b31693d5', 'Rishabh', 'Ranjan', '80f49cf062'); # password6

insert into THERAPISTS (Email) values
('rishabh@gmail.com'),
('aditi@gmail.com'),
('andrew@gmail.com');

insert into PATIENTS (Email, Therapist) values
('paula@gmail.com', 'rishabh@gmail.com'),
('emma@gmail.com', null),
('jessica@gmail.com', 'andrew@gmail.com');

insert into EXERCISES (ID, ExerciseName, ExerciseDescription, Picture, Video, Duration, Frequency) values
(10001, "Seated Marching", "Sit fully back into your chair with your back straight. Alternate lifting legs up and down, as if you are marching up and down stairs. Repeat for 10 repetitions on each leg. Rest for about 30 seconds and repeat the exercise.", "path/to/seated/marching.jpeg", null, "5 minutes", "Monday;Wednesday;Friday"),
(10002, "Leg Rotation", "Draw-in your navel and contract your glutes. Balance on one leg and lift the other until your knee is at waist level. Rotating at the hip, bring your lifted leg toward the side of your body and then back to the front. Hold each point for a few seconds then return to the starting position", "path/to/rotated/leg.jpeg", null, "3 minutes", "Tuesday:Thursday:Saturday"),
(10003, "Open Arm Exercise", "While keep your arms straight, move them back as far as possible until you feel the stretch in your chest. Hold for 10 to 20 seconds and then relax. When doing the exercise, release all tension from your body, keep your head up, open your chest and breathe out as you stretch the muscles. Don't force yourself into any position, let your chest muscles relax before you try to move forward into a deeper stretch", "path/to/arm/stretching.jpeg", null, "6 minutes", "Monday;Tuesday;Wednesday;Thursday"),
(10004, "Weight Bearing Lean", "Stand facing a wall a little farther than arm's length away from it. Your feet should be slightly apart, arms bent at the elbows and hands at shoulder height flat against the wall. Do not round your back. Bend at the elbows and lean your body forward towards the wall by bending your elbows in a controlled movement as you count to 5. Pause. Then, slowly push yourself back until your arms are straight as you count to 4. Make sure you do not lock your elbows. Repeat the wall push-up 10 times. Rest for about 1 minute. Then do a second set of 10 wall push-ups.", "path/to/weight/bearing.jpeg", null, "10 minutes", "Friday;Saturday;Sunday");

insert into ASSIGNMENTS 
(ID, Patient, Therapist, ExerciseID, ExerciseName, ExerciseDescription, ExercisePicture, ExerciseVideo, ExpectedDuration, 
ExerciseFrequency, ExerciseStatus, ActualDuration, ExerciseDifficulty, ExerciseComment) values
(1001, "paula@gmail.com", "rishabh@gmail.com", 10001, "Seated Marching", "Sit fully back into your chair with your back straight. Alternate lifting legs up and down, as if you are marching up and down stairs. Repeat for 10 repetitions on each leg. Rest for about 30 seconds and repeat the exercise.", "path/to/seated/marching.jpeg", null, "5 minutes", "Monday;Wednesday;Friday",
"COMPLETED", "10 minutes", "MODERATE", "My legs felt numb after the exercise"),
(1002, "paula@gmail.com", "rishabh@gmail.com", null, "Wall Slide", "Stand with your back to the wall, heels at least one shoe-length from the wall. Avoid knees in front of toes with exercise. May use a chair in front for safety if needed. Point your feet straight ahead and shoulder-width apart. Place your buttocks, palms of your hands and shoulders against the wall. Tuck your chin. The back of your head should be as close to the wall as possible. Tighten your stomach muscles during the entire exercise. Slide up and down the wall and get as close to a sitting position as possible. It may take several days or weeks to reach this position. Repeat this 10 times. Remember: Keep your shoulders back. Keep your stomach and back flat.", 
"path/to/wall/slide.jpeg", null, "10 minutes", "Tuesday;Thursday", "COMPLETED", "15 minutes", "HARD", "I could not put my back straight on the wall"),
(1003, "paula@gmail.com", "rishabh@gmail.com", 10002, "Leg Rotation", "Draw-in your navel and contract your glutes. Balance on one leg and lift the other until your knee is at waist level. Rotating at the hip, bring your lifted leg toward the side of your body and then back to the front. Hold each point for a few seconds then return to the starting position", "path/to/rotated/leg.jpeg", null, "3 minutes", "Tuesday:Thursday:Saturday",
"COMPLETED", "10 minutes", "EASY", "This exercise is not too hard. I was able to complete it without feeling exhausted"),
(1004, "paula@gmail.com", "rishabh@gmail.com", 10003, "Open Arm Exercise", "While keep your arms straight, move them back as far as possible until you feel the stretch in your chest. Hold for 10 to 20 seconds and then relax. When doing the exercise, release all tension from your body, keep your head up, open your chest and breathe out as you stretch the muscles. Don't force yourself into any position, let your chest muscles relax before you try to move forward into a deeper stretch", "path/to/arm/stretching.jpeg", null, "6 minutes", "Monday;Tuesday;Wednesday;Thursday",
"COMPLETED", "10 minutes", "MODERATE", null),
(1005, "paula@gmail.com", "rishabh@gmail.com", 10004, "Weight Bearing Lean", "Stand facing a wall a little farther than arm's length away from it. Your feet should be slightly apart, arms bent at the elbows and hands at shoulder height flat against the wall. Do not round your back. Bend at the elbows and lean your body forward towards the wall by bending your elbows in a controlled movement as you count to 5. Pause. Then, slowly push yourself back until your arms are straight as you count to 4. Make sure you do not lock your elbows. Repeat the wall push-up 10 times. Rest for about 1 minute. Then do a second set of 10 wall push-ups.", "path/to/weight/bearing.jpeg", null, "10 minutes", "Friday;Saturday;Sunday",
"ASSIGNED", null, null, null);

