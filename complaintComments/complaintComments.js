import { LightningElement, api, wire, track } from 'lwc';
import getCaseComments from '@salesforce/apex/ComplaintController.getCaseComments';
import addCaseComment from '@salesforce/apex/ComplaintController.addCaseComment';

export default class ComplaintComments extends LightningElement {
    @api recordId;
    @track comments = [];
    @track displayedComments = [];
    @track newComment = '';
    commentLimit = 5;

    connectedCallback() {
        this.loadComments();
    }

    handleCommentChange(event) {
        this.newComment = event.target.value;
    }

    addComment() {
        if (this.newComment.trim()) {
            addCaseComment({ caseId: this.recordId, commentText: this.newComment })
                .then(() => {
                    this.newComment = '';
                    this.loadComments();
                })
                .catch(err => console.error(err));
        }
    }

    loadComments() {
        console.log('record id ',this.recordId);
        getCaseComments({ caseId: this.recordId })
            .then(data => {
                this.comments = data.map(c => ({
                    Id: c.Id,
                    CommentBody: c.CommentBody,
                    CreatedDate: c.CreatedDate,
                    OwnerName: c.CreatedBy?.Name
                }));
                this.displayedComments = this.comments.slice(0, this.commentLimit);
            })
            .catch(error => console.error(error));
    }

    loadMoreComments() {
        this.commentLimit += 5;
        this.displayedComments = this.comments.slice(0, this.commentLimit);
    }

    get showViewMore() {
        return this.comments.length > this.displayedComments.length;
    }
}