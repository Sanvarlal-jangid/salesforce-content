import { LightningElement, track, wire } from 'lwc';
import quizeQuestion from '@salesforce/apex/questionController.quizeQuestion';
import { createRecord } from 'lightning/uiRecordApi';

export default class LWCassignment extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track quizQuestions = [];
    @track reviewData = [];
    @track index = 0;
    @track question; 
    @track form = true;
    @track quizStarted = false;
    @track showFinish = false;
    @track showReview = false;
    @track showScore = false;
    @track selectedAnswers = {};
    @track score = 0;
    @track visitedQuestions = new Set();

    // Getter to provide the currently selected option for the displayed question
    get currentQuestionSelectedOption() {
        return this.question ? this.selectedAnswers[this.question.Id] : undefined;
    }

    // Getters for individual radio button checked states (quiz section)
    get isOptionAChecked() {
        return this.currentQuestionSelectedOption === 'A';
    }

    get isOptionBChecked() {
        return this.currentQuestionSelectedOption === 'B';
    }

    get isOptionCChecked() {
        return this.currentQuestionSelectedOption === 'C';
    }

    get isOptionDChecked() {
        return this.currentQuestionSelectedOption === 'D';
    }

    @wire(quizeQuestion)
    wiredQuestions({ error, data }) {
        if (data) {
            this.quizQuestions = data;
        } else if (error) {
            console.error('Error fetching quiz questions:', error);
        }
    }

    handleInputChangeF(event) {
        this.firstName = event.target.value;
    }

    handleInputChangeL(event) {
        this.lastName = event.target.value;
    }

    handleInputChangeE(event) {
        this.email = event.target.value;
    }

    handleSave() {
        if (this.firstName && this.lastName && this.email) {
            const fields = {
                'First_Name__c': this.firstName,
                'Last_Name__c': this.lastName,
                'Email__c': this.email
            };
            const recordInput = { apiName: 'Quiz_Attendee__c', fields };

            createRecord(recordInput)
                .then(attendee => {
                    console.log('Quiz Attendee record created:', attendee.id);
                    this.form = false;
                    this.quizStarted = true;
                    if (this.quizQuestions.length > 0) {
                         this.question = this.quizQuestions[this.index];
                    } else {
                        console.warn('Quiz questions not loaded yet when trying to start quiz.');
                    }
                })
                .catch(error => {
                    console.error('Error creating Quiz Attendee record:', error);
                });
        } else {
            console.log('Please fill in all details (First Name, Last Name, Email).');
        }
    }

    handleOptionSelect(event) {
        this.selectedAnswers = {
            ...this.selectedAnswers,
            [this.question.Id]: event.target.value
        };
    }

    handleNext() {
        this.visitedQuestions.add(this.question.Id);

        if (this.index < this.quizQuestions.length - 1) {
            this.index++;
            this.question = this.quizQuestions[this.index];
        }

        if (this.visitedQuestions.size === this.quizQuestions.length) {
            this.showFinish = true;
        }
    }

    handlePrevious() {
        if (this.index > 0) {
            this.index--;
            this.question = this.quizQuestions[this.index];
        }
    }

    handleFinish() {
        this.visitedQuestions.add(this.question.Id);
        this.quizStarted = false;
        this.calculateScore();

        console.log('Quiz finished. Score calculated, but not saved to Salesforce with current setup.');
        this.showScore = true;
        this.showFinish = false;
    }

    calculateScore() {
        let correct = 0;
        this.quizQuestions.forEach(q => {
            const selected = this.selectedAnswers[q.Id];
            if (selected === q.Correct_Answer__c) {
                correct++;
            }
        });
        this.score = correct;
    }

    handleSeeAnswers() {
        this.showScore = false;
        this.showReview = true;
        this.prepareReviewData();
    }

    prepareReviewData() {
        this.reviewData = this.quizQuestions.map(q => {
            const userAnswer = this.selectedAnswers[q.Id];
            const correctAns = q.Correct_Answer__c;

            return {
                ...q, // Copy all original question properties
                selected: userAnswer,
                // Create an array of option objects with their determined class
                reviewOptions: [
                    { label: q.OptionA__c, value: 'A', class: this.getOptionClass('A', userAnswer, correctAns) },
                    { label: q.OptionB__c, value: 'B', class: this.getOptionClass('B', userAnswer, correctAns) },
                    { label: q.OptionC__c, value: 'C', class: this.getOptionClass('C', userAnswer, correctAns) },
                    { label: q.OptionD__c, value: 'D', class: this.getOptionClass('D', userAnswer, correctAns) }
                ]
            };
        });
    }

    // Re-added helper to determine CSS class for options during review
    getOptionClass(optionValue, userAnswer, correctAnswer) {
        if (optionValue === correctAnswer) {
            return 'green-text'; 
        } else if (optionValue === userAnswer && optionValue !== correctAnswer) {
            return 'red-text'; 
        }
        return '';
    }

    // --- Getters for HTML rendering logic ---
   

    get isFirstQuestionQuiz() {
        return this.index === 0;
    }
}