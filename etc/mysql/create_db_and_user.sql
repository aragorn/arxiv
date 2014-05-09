
create database if not exists arxiv
    default character set = utf8mb4
    default collate = utf8mb4_general_ci
    ;

grant all on `arxiv`.* to 'arxiv'@'localhost';

