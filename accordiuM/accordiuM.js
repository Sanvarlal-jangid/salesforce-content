import { LightningElement, wire, track } from 'lwc';

import getHiringstudent from '@salesforce/apex/collegeStudentinfo.getHiringstudent';


export default class StudentAccordion extends LightningElement {
    @track groupedData;
    @track error;

    columns = [
        { label: 'Student Name', fieldName: 'name' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        { label: 'Status', fieldName: 'status' }
    ];

    connectedCallback() {
        getHiringstudent()
            .then(data => {
                console.log('data:', data);
                this.groupedData = this.groupData(data);
            })
            .catch(error => {
                this.error = error.body.message;
                console.error('Error:', error);
            });
    }

    // groupData(data) {
    //     const collegeMap = {};

    //     data.forEach(record => {
    //         const collegeName = record.College_Information__r.Name;
    //         console.log(collegeName)
    //         const year = record.Year__c;
    //         const profile = record.Profile__c;


    //         if (!collegeMap[collegeName]) {
    //             collegeMap[collegeName] = {
    //                 name: collegeName,
    //                 yearsMap: {}
    //             };
    //         }

    //         if (!collegeMap[collegeName].yearsMap[year]) {
    //             collegeMap[collegeName].yearsMap[year] = {
    //                 value: year,
    //                 profilesMap: {}
    //             };
    //         }


    //         if (!collegeMap[collegeName].yearsMap[year].profilesMap[profile]) {
    //             collegeMap[collegeName].yearsMap[year].profilesMap[profile] = {
    //                 name: profile,
    //                 students: []
    //             };
    //         }


    //         const student = {
    //             id: record.Id,
    //             name: record.Name,
    //             email: record.Student_Email__c,
    //             phone: record.Student_Phone_Number__c,
    //             status: record.Status__c
    //         };

    //         collegeMap[collegeName]
    //             .yearsMap[year]
    //             .profilesMap[profile]
    //             .students
    //             .push(student);
    //     });

    //     console.log(collegeMap);
    //     return Object.values(collegeMap).map(college => {
    //         college.years = Object.values(college.yearsMap).map(year => {
    //             year.profiles = Object.values(year.profilesMap);
    //             return year;
    //         });
    //         return college;
    //     });



    groupData(data) {
        console.log('enters into function');
        const result = [];
        

        data.forEach(record => {
            const collegeName = record.College_Information__r.Name;
            const year = record.Year__c;
            const profile = record.Profile__c;
            
                let college = result.find(c => c.name === collegeName);
            if (!college) {
                college = { name: collegeName, years: [] };
                result.push(college);
            }

            let yearGroup = college.years.find(y => y.year === year);
            if (!yearGroup) {
                yearGroup = { year: year, profiles: [] };
                college.years.push(yearGroup);
            }

            let profileGroup = yearGroup.profiles.find(p => p.name === profile);
            if (!profileGroup) {
                profileGroup = { name: profile, students: [] };
                yearGroup.profiles.push(profileGroup);
            }
           
             
            const student = {
                id: record.Id,
                name: record.Name,
                email: record.Student_Email__c,
                phone: record.Student_Phone_Number__c,
                status: record.Status__c
            };
            profileGroup.students.push(student);

           

            
        });
         
       console.log('result is this',result);
        return result;
    }
}