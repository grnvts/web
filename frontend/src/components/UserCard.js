import defaultPicture from "../assets/profile.png";
import React, { useEffect, useState } from 'react';
import { withTranslation } from 'react-i18next';
import ProfileImage from "./ProfileImage";
import Moment from "react-moment";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
    faUser,
    faEnvelope,
    faPhone,
    faBirthdayCake,
    faClock,
    faIdCard,
    faSignature
} from '@fortawesome/free-solid-svg-icons';
import './UserCard.css';

const UserCard = (props) => {
    const [user, setUser] = useState({});
    const { username, name, surname, patronymic, image, email, bornDate, createdDate, phone } = user;
    const { t } = props;
    let imageSource = defaultPicture;

    useEffect(() => {
        setUser(props.user);
    }, [props.user])

    if (image) {
        imageSource = image;
    }

    return (
        <div className="user-profile-container">
            <div className="user-profile-card">
                <div className="profile-header">
                    <div className="profile-image-container">
                        <ProfileImage
                            width="200px"
                            height="200px"
                            imageSource={imageSource}
                            newimage={props.newImage}
                            username={username}
                        />
                    </div>
                    <div className="profile-title">
                        <h2>{surname} {name}</h2>
                        <p className="username">@{username}</p>
                    </div>
                </div>

                <div className="profile-info">
                    <div className="info-section">
                        <h3>{t('Personal Information')}</h3>
                        <div className="info-grid">
                            <div className="info-item">
                                <FontAwesomeIcon icon={faUser} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Username')}</label>
                                    <span>{username}</span>
                                </div>
                            </div>

                            <div className="info-item">
                                <FontAwesomeIcon icon={faSignature} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Full Name')}</label>
                                    <span>{surname} {name} {patronymic}</span>
                                </div>
                            </div>

                            <div className="info-item">
                                <FontAwesomeIcon icon={faPhone} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Phone')}</label>
                                    <span>{phone || t('Not specified')}</span>
                                </div>
                            </div>

                            <div className="info-item">
                                <FontAwesomeIcon icon={faEnvelope} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Email')}</label>
                                    <span>{email}</span>
                                </div>
                            </div>

                            <div className="info-item">
                                <FontAwesomeIcon icon={faBirthdayCake} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Born Date')}</label>
                                    <span>{bornDate ? <Moment format="DD.MM.YYYY">{bornDate}</Moment> : t('Not specified')}</span>
                                </div>
                            </div>

                            <div className="info-item">
                                <FontAwesomeIcon icon={faClock} className="info-icon" />
                                <div className="info-content">
                                    <label>{t('Member Since')}</label>
                                    <span>{createdDate && <Moment format="DD.MM.YYYY">{createdDate}</Moment>}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default withTranslation()(UserCard);