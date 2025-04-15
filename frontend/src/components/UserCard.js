import defaultPicture from "../assets/profile.png";
import React, { useEffect, useState } from 'react';
import { withTranslation } from 'react-i18next';
import ProfileImage from "./ProfileImage";
import Moment from "react-moment";

const UserCard = (props) => {
    const [user, setUser] = useState({});
    const { username, name, surname, patronymic, image, email, bornDate, createdDate, phone} = user;
    const { t } = props; // Получаем функцию перевода из props
    let imageSource = defaultPicture;

    useEffect(() => {
        setUser(props.user);
    }, [props.user])

    if (image) {
        imageSource = image;
    }

    return (
        <div className="container">
            <div className="card">
                <div className="card-header text-center">
                    <ProfileImage
                        width="200px"
                        height="200px"
                        imageSource={imageSource}
                        newimage={props.newImage}
                        username={username}
                    />
                </div>

                <ul className="list-group list-group-flush">
                    <li className="list-group-item"><b>{t('Username')}:</b> {username}</li>
                    {/*<li className="list-group-item"><b>{t('Full Name')}:</b> {fullName}</li>*/}
                    <li className="list-group-item"><b>{t('Surname')}:</b> {surname}</li>
                    <li className="list-group-item"><b>{t('Name')}:</b> {name}</li>
                    <li className="list-group-item"><b>{t('Patronymic')}:</b> {patronymic}</li>

                    <li className="list-group-item"><b>{t('Phone')}:</b> {phone}</li>
                    <li className="list-group-item"><b>{t('Email')}:</b> {email}</li>
                    <li className="list-group-item"><b>{t('Born Date')}:</b>  {bornDate && <Moment format=" YYYY / MM / DD">{bornDate}</Moment>}</li>
                    <li className="list-group-item"><b>{t('Created Date')}:</b> {createdDate && <Moment format="DD/MM/YYYY, HH:MM">{createdDate}</Moment>}</li>

                </ul>
            </div>
        </div>
    );
};

export default withTranslation()(UserCard);