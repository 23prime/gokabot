export class Message {
    public id?: number;
    public text?: string;
    public sender?: string;

    constructor(id: number, text?: string, sender?: string) {
        this.id = id;
        this.text = text;
        this.sender = sender;
    }
}
