class Assignment {
    constructor(ID, Patient, Therapist, ExerciseName, ExerciseDescription, ExercisePicture, 
        ExerciseVideo, ExerciseDuration, ExerciseFrequency, ExerciseStatus, ReportedDuration, 
        ReportedDifficulty, PatientComment) {
        this.ID = ID;
        this.Patient = Patient;
        this.Therapist = Therapist;
        this.ExerciseName = ExerciseName;
        this.ExerciseDescription = ExerciseDescription;
        this.ExercisePicture = ExercisePicture;
        this.ExerciseVideo = ExerciseVideo;
        this.ExerciseDuration = ExerciseDuration;
        this.ExerciseFrequency = ExerciseFrequency;
        this.ExerciseStatus = ExerciseStatus;
        this.ReportedDuration = ReportedDuration;
        this.ReportedDifficulty = ReportedDifficulty;
        this.PatientComment = PatientComment;
    }
}

module.exports = Assignment;