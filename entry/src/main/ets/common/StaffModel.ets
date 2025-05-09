export class Staff {
  id?: number;
  name: string;
  position: string;
  department: string;
  phone: string;
  status: string;
  issueDate: string;
  expiryDate: string;
  healthCert: string;

  constructor(
    name: string = '',
    position: string = '',
    department: string = '实训第二学校餐厅',
    phone: string = '',
    status: string = '在职',
    issueDate: string = '',
    expiryDate: string = '',
    healthCert: string = '',
    id?: number
  ) {
    this.id = id;
    this.name = name;
    this.position = position;
    this.department = department;
    this.phone = phone;
    this.status = status;
    this.issueDate = issueDate;
    this.expiryDate = expiryDate;
    this.healthCert = healthCert;
  }
} 