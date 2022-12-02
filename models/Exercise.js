class Exercise {
    constructor(ID, name, description, picture, video, time, frequency) {
        this.ID = ID;
        this.ExerciseName = name;
        this.ExerciseDescription = description;
        this.ExercisePicture = picture;
        this.ExerciseVideo = video;
        this.ExerciseDuration = time;
        this.ExerciseFrequency = frequency;
    }
}

module.exports = Exercise;